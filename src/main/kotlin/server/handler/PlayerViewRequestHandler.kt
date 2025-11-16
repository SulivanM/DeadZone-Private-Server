package server.handler

import context.ServerContext
import core.model.game.data.destroyed
import core.model.game.data.id
import core.model.game.data.level
import core.model.game.data.resourceValue
import core.model.game.data.rotation
import core.model.game.data.tx
import core.model.game.data.ty
import core.model.game.data.type
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import common.Time
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer

/**
 * Handle `pvr` (PLAYER_VIEW_REQUEST) message.
 *
 * AS3 Client: Network.send("pvr", {"id": neighbor.id}, callback)
 *
 * Sent when player navigates to view another player's compound (without attacking).
 * Simple viewing returns only building layout data.
 *
 * Response: {"buildings": [{id, type, level, tx, ty, rotation, destroyed, ...}, ...]}
 *
 * From: Game.as:468-499
 */
class PlayerViewRequestHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.PLAYER_VIEW_REQUEST ||
                message.contains(NetworkMessage.PLAYER_VIEW_REQUEST)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "PLAYER_VIEW_REQUEST: No playerId in connection" }
            return
        }

        val requestData = message.getMap(NetworkMessage.PLAYER_VIEW_REQUEST)
        val messageId = requestData?.get("id") as? String ?: "m"
        val data = requestData?.get("data") as? Map<*, *>
        val targetPlayerId = data?.get("id") as? String

        if (targetPlayerId == null) {
            Logger.warn(LogConfigSocketToClient) {
                "PLAYER_VIEW_REQUEST: Invalid request from playerId=$playerId"
            }
            val errorResponse = listOf(
                NetworkMessage.SEND_RESPONSE,
                messageId,
                Time.now(),
                """{"error":"Invalid target player"}"""
            )
            send(PIOSerializer.serialize(errorResponse))
            return
        }

        Logger.debug(LogConfigSocketToClient) {
            "PLAYER_VIEW_REQUEST: Player $playerId viewing player $targetPlayerId"
        }

        val playerObjects = serverContext.db.loadPlayerObjects(targetPlayerId)
        if (playerObjects == null) {
            val errorResponse = listOf(
                NetworkMessage.SEND_RESPONSE,
                messageId,
                Time.now(),
                """{"error":"Player not found"}"""
            )
            send(PIOSerializer.serialize(errorResponse))
            return
        }

        val buildingsJson = buildString {
            append("[")
            append(playerObjects.buildings.joinToString(",") { building ->
                buildString {
                    append("{\"id\":\"${building.id}\",")
                    append("\"type\":\"${building.type}\",")
                    append("\"level\":${building.level},")
                    append("\"tx\":${building.tx},")
                    append("\"ty\":${building.ty},")
                    append("\"rotation\":${building.rotation},")
                    append("\"destroyed\":${building.destroyed},")
                    append("\"resourceValue\":${building.resourceValue}")
                    append("}")
                }
            })
            append("]")
        }

        val responseJson = """{"buildings":$buildingsJson}"""
        val response = listOf(
            NetworkMessage.SEND_RESPONSE,
            messageId,
            Time.now(),
            responseJson
        )
        send(PIOSerializer.serialize(response))

        Logger.debug(LogConfigSocketToClient) {
            "PLAYER_VIEW_REQUEST: Sent ${playerObjects.buildings.size} buildings for player $targetPlayerId"
        }
    }
}
