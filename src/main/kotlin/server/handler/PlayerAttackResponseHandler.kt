package server.handler

import context.ServerContext
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import common.Time
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer

/**
 * Handle `parp` (PLAYER_ATTACK_RESPONSE) message.
 *
 * AS3 Client: Network.send("parp", {"id": "m0", "data": {"id": opponentId, "cancelled": true}}, callback)
 *
 * Sent when player cancels attack during mission planning phase.
 * Simple acknowledgment response expected.
 */
class PlayerAttackResponseHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.PLAYER_ATTACK_RESPONSE ||
                message.contains(NetworkMessage.PLAYER_ATTACK_RESPONSE)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "PLAYER_ATTACK_RESPONSE: No playerId in connection" }
            return
        }

        val body = message.getMap(NetworkMessage.PLAYER_ATTACK_RESPONSE)
        val messageId = body?.get("id") as? String ?: "m"
        val data = body?.get("data") as? Map<*, *>

        val opponentId = data?.get("id") as? String
        val cancelled = data?.get("cancelled") as? Boolean ?: false

        Logger.debug(LogConfigSocketToClient) {
            "PLAYER_ATTACK_RESPONSE: Player $playerId ${if (cancelled) "cancelled" else "responded to"} attack on $opponentId"
        }

        val responseJson = """{"status":"success"}"""
        val response = listOf(
            NetworkMessage.SEND_RESPONSE,
            messageId,
            Time.now(),
            responseJson
        )
        send(PIOSerializer.serialize(response))
    }
}
