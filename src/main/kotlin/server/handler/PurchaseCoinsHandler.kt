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
 * Handle `p` (PURCHASE_COIN) message.
 *
 * AS3 Client sends: Network.send("p", null, callback)
 *
 * This is sent to check/update coin balance after a purchase.
 * The actual purchase validation happens outside this system (via PlayerIO, Steam, etc.)
 *
 * Expected response:
 * ```json
 * {"coins": 1000}
 * ```
 *
 * From: PaymentSystem.as:973
 */
class PurchaseCoinsHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.PURCHASE_COIN ||
                message.contains(NetworkMessage.PURCHASE_COIN)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "PURCHASE_COINS: No playerId in connection" }
            return
        }

        // Extract request data
        val body = message.getMap(NetworkMessage.PURCHASE_COIN)
        val messageId = body?.get("id") as? String ?: "m"

        Logger.debug(LogConfigSocketToClient) {
            "PURCHASE_COINS: Player $playerId requesting coin balance"
        }

        // Load player's current coin balance
        val playerObjects = serverContext.db.loadPlayerObjects(playerId)
        if (playerObjects == null) {
            Logger.warn(LogConfigSocketToClient) {
                "PURCHASE_COINS: PlayerObjects not found for playerId=$playerId"
            }
            val errorResponse = listOf(
                NetworkMessage.SEND_RESPONSE,
                messageId,
                Time.now(),
                """{"error":"Player data not found"}"""
            )
            send(PIOSerializer.serialize(errorResponse))
            return
        }

        // Return current coin balance
        val coins = playerObjects.resources.cash
        val responseJson = """{"coins":$coins}"""

        val response = listOf(
            NetworkMessage.SEND_RESPONSE,
            messageId,
            Time.now(),
            responseJson
        )
        send(PIOSerializer.serialize(response))

        Logger.debug(LogConfigSocketToClient) {
            "PURCHASE_COINS: Sent coin balance ($coins) to player $playerId"
        }
    }
}
