package server.handler

import context.ServerContext
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put
import kotlinx.serialization.json.putJsonObject
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer

/**
 * Handle `ns` (GET_NEIGHBOR_STATES) message.
 *
 * AS3 Client: RemotePlayerManager.updateNeighborStates() sends connection.send("ns")
 * Format: ["ns"]
 *
 * Returns neighbor list with online status, lastLogin, and other social data.
 * Used to display neighbor lists with online/offline indicators.
 *
 * Response: ["ns", '{"neighbors": {neighborId: {...}, ...}}']
 *
 * From: MapOverlay.as:846, RemotePlayerManager.as, RemotePlayerData.as:605-617
 */
class GetNeighborStatesHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.GET_NEIGHBOR_STATES ||
                message.contains(NetworkMessage.GET_NEIGHBOR_STATES)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "GET_NEIGHBOR_STATES: No playerId in connection" }
            return
        }

        Logger.debug(LogConfigSocketToClient) {
            "GET_NEIGHBOR_STATES: Player $playerId requesting neighbor states"
        }

        val playerObjects = serverContext.db.loadPlayerObjects(playerId)
        if (playerObjects == null) {
            Logger.warn(LogConfigSocketToClient) {
                "GET_NEIGHBOR_STATES: PlayerObjects not found for playerId=$playerId"
            }
            return
        }

        val neighbors = playerObjects.neighbors ?: emptyMap()
        val currentTime = System.currentTimeMillis()

        val neighborsJson = buildJsonObject {
            putJsonObject("neighbors") {
                neighbors.forEach { (neighborId, neighborData) ->
                    putJsonObject(neighborId) {
                        neighborData.name?.let { put("name", it) }
                        neighborData.nickname?.let { put("nickname", it) }
                        neighborData.level?.let { put("level", it) }
                        neighborData.serviceUserId?.let { put("serviceUserId", it) }
                        neighborData.lastLogin?.let { put("lastLogin", it) }
                        neighborData.allianceId?.let { put("allianceId", it) }
                        neighborData.allianceTag?.let { put("allianceTag", it) }
                        neighborData.allianceName?.let { put("allianceName", it) }
                        neighborData.bounty?.let { put("bounty", it) }
                        neighborData.bountyDate?.let { put("bountyDate", it) }

                        val isOnline = serverContext.onlinePlayerRegistry.isOnline(neighborId)
                        put("online", isOnline)
                        put("onlineTimestamp", currentTime)

                        put("underAttack", false)
                        put("protected", false)
                        put("banned", false)
                    }
                }
            }
        }

        val response = listOf(
            NetworkMessage.GET_NEIGHBOR_STATES,
            Json.encodeToString(kotlinx.serialization.json.JsonObject.serializer(), neighborsJson)
        )
        send(PIOSerializer.serialize(response))

        Logger.debug(LogConfigSocketToClient) {
            "GET_NEIGHBOR_STATES: Sent ${neighbors.size} neighbor states for player $playerId"
        }
    }
}
