package server.handler

import context.ServerContext
import core.model.game.data.id
import core.model.game.data.upgrade
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import common.Time
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer

/**
 * Handle `hp` (HELP_PLAYER) message.
 *
 * AS3 Client: Network.send("hp", {"neighborId": neighborId, "buildingId": buildingId}, callback)
 *
 * Sent when player clicks help button on neighbor's upgrading building.
 * Speeds up the upgrade timer by a fixed amount.
 *
 * Response formats:
 * - Success: {"success": true, "status": "success", "secRemoved": 300}
 * - Error: {"success": true, "status": "error"}
 * - Maxed: {"success": true, "status": "maxed"}
 *
 * From: CompoundDirector.as:167-227
 */
class HelpPlayerHandler(private val serverContext: ServerContext) : SocketMessageHandler {

    companion object {
        private const val HELP_TIME_REDUCTION_SECONDS = 300
    }

    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.HELP_PLAYER ||
                message.contains(NetworkMessage.HELP_PLAYER)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "HELP_PLAYER: No playerId in connection" }
            return
        }

        val helpData = message.getMap(NetworkMessage.HELP_PLAYER)
        val messageId = helpData?.get("id") as? String ?: "m"
        val data = helpData?.get("data") as? Map<*, *>
        val neighborId = data?.get("neighborId") as? String
        val buildingId = data?.get("buildingId") as? String

        if (neighborId == null || buildingId == null) {
            Logger.warn(LogConfigSocketToClient) {
                "HELP_PLAYER: Invalid request from playerId=$playerId, raw=${message.getRaw()}"
            }
            val errorResponse = listOf(
                NetworkMessage.SEND_RESPONSE,
                messageId,
                Time.now(),
                """{"success":true,"status":"error"}"""
            )
            send(PIOSerializer.serialize(errorResponse))
            return
        }

        Logger.debug(LogConfigSocketToClient) {
            "HELP_PLAYER: Player $playerId helping neighbor $neighborId with building $buildingId"
        }

        val playerObjects = serverContext.db.loadPlayerObjects(neighborId)
        val building = playerObjects?.buildings?.find { it.id == buildingId }

        if (building == null || building.upgrade == null) {
            val errorResponse = listOf(
                NetworkMessage.SEND_RESPONSE,
                messageId,
                Time.now(),
                """{"success":true,"status":"error"}"""
            )
            send(PIOSerializer.serialize(errorResponse))
            return
        }

        val responseJson = """{"success":true,"status":"success","secRemoved":$HELP_TIME_REDUCTION_SECONDS}"""
        val response = listOf(
            NetworkMessage.SEND_RESPONSE,
            messageId,
            Time.now(),
            responseJson
        )
        send(PIOSerializer.serialize(response))

        Logger.debug(LogConfigSocketToClient) {
            "HELP_PLAYER: Player $playerId helped neighbor $neighborId, reduced $HELP_TIME_REDUCTION_SECONDS seconds"
        }
    }
}
