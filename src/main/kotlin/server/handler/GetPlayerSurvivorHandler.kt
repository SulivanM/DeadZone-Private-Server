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
 * Handle `ps` (GET_PLAYER_SURVIVOR) message.
 *
 * AS3 Client: Network.send("ps", {"id": attackerId, "weapon": true}, callback)
 *
 * Sent when viewing an attack report to display the attacker's survivor.
 * Returns survivor data with optional weapon/loadout info.
 *
 * Response: {"survivor": {...complete survivor data...}, "weapon": {...weapon item...}}
 *
 * From: AttackReportDialogue.as:389-414
 */
class GetPlayerSurvivorHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.GET_PLAYER_SURVIVOR ||
                message.contains(NetworkMessage.GET_PLAYER_SURVIVOR)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "GET_PLAYER_SURVIVOR: No playerId in connection" }
            return
        }

        val requestData = message.getMap(NetworkMessage.GET_PLAYER_SURVIVOR)
        val messageId = requestData?.get("id") as? String ?: "m"
        val data = requestData?.get("data") as? Map<*, *>
        val targetPlayerId = data?.get("id") as? String
        val includeWeapon = data?.get("weapon") as? Boolean ?: false

        if (targetPlayerId == null) {
            Logger.warn(LogConfigSocketToClient) {
                "GET_PLAYER_SURVIVOR: Invalid request from playerId=$playerId"
            }
            val errorResponse = listOf(
                NetworkMessage.SEND_RESPONSE,
                messageId,
                Time.now(),
                """{"error":"Invalid request"}"""
            )
            send(PIOSerializer.serialize(errorResponse))
            return
        }

        Logger.debug(LogConfigSocketToClient) {
            "GET_PLAYER_SURVIVOR: Player $playerId requesting survivor for $targetPlayerId (weapon=$includeWeapon)"
        }

        val playerObjects = serverContext.db.loadPlayerObjects(targetPlayerId)
        val survivor = playerObjects?.survivors?.firstOrNull()

        if (survivor == null) {
            val errorResponse = listOf(
                NetworkMessage.SEND_RESPONSE,
                messageId,
                Time.now(),
                """{"error":"Survivor not found"}"""
            )
            send(PIOSerializer.serialize(errorResponse))
            return
        }

        val survivorJson = buildString {
            append("{\"id\":\"${survivor.id}\",")
            append("\"title\":\"${survivor.title}\",")
            append("\"firstName\":\"${survivor.firstName}\",")
            append("\"lastName\":\"${survivor.lastName}\",")
            append("\"gender\":\"${survivor.gender}\",")
            append("\"portrait\":${survivor.portrait?.let { "\"$it\"" } ?: "null"},")
            append("\"classId\":\"${survivor.classId}\",")
            append("\"level\":${survivor.level},")
            append("\"xp\":${survivor.xp},")
            append("\"scale\":${survivor.scale},")
            append("\"voice\":\"${survivor.voice}\",")
            append("\"morale\":{},")
            append("\"injuries\":[")
            append(survivor.injuries.joinToString(",") { injury ->
                val healTime = injury.timer?.let { it.start + it.length * 1000 } ?: 0L
                "{\"id\":\"${injury.id}\",\"cause\":\"${injury.type}\",\"healTime\":$healTime}"
            })
            append("],")
            append("\"missionId\":${survivor.missionId?.let { "\"$it\"" } ?: "null"},")
            append("\"assignmentId\":${survivor.assignmentId?.let { "\"$it\"" } ?: "null"}")
            append("}")
        }

        val responseJson = if (includeWeapon) {
            """{"survivor":$survivorJson,"weapon":null}"""
        } else {
            """{"survivor":$survivorJson}"""
        }

        val response = listOf(
            NetworkMessage.SEND_RESPONSE,
            messageId,
            Time.now(),
            responseJson
        )
        send(PIOSerializer.serialize(response))

        Logger.debug(LogConfigSocketToClient) {
            "GET_PLAYER_SURVIVOR: Sent survivor ${survivor.id} for $targetPlayerId"
        }
    }
}
