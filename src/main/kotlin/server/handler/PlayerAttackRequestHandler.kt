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
 * Handle `par` (PLAYER_ATTACK_REQUEST) message.
 *
 * AS3 Client: Network.send("par", {"id": targetPlayerId, "allianceMatchRequest": false}, callback)
 *
 * Sent when player initiates attack on another player's compound.
 * 
 * **Raiding Practice Mode:**
 * When `id` is null, the player is attacking their own compound for practice.
 * This allows players to test their defenses without consequences.
 * The server returns the requesting player's own compound data.
 * 
 * Returns complete compound data for PvP mission planning including:
 * - Buildings layout and defenses
 * - Defenders (survivors) with rally assignments
 * - Resources available to loot
 * - Research effects
 * - Loadout data (weapons/gear equipped)
 * - Alliance match data if applicable
 *
 * Response status values:
 * - "success": Attack allowed, compound data provided
 * - "disabled": PvP disabled for target
 * - "protected": Target under protection
 * - "underAttack": Target already in mission
 * - "online": Target currently online (optional restriction)
 * - "sameIP": Same IP address detected
 * - "error": Generic error
 *
 * From: Game.as:637-705
 */
class PlayerAttackRequestHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.PLAYER_ATTACK_REQUEST ||
                message.contains(NetworkMessage.PLAYER_ATTACK_REQUEST)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "PLAYER_ATTACK_REQUEST: No playerId in connection" }
            return
        }

        val requestData = message.getMap(NetworkMessage.PLAYER_ATTACK_REQUEST)
        val messageId = requestData?.get("id") as? String ?: "m"
        val data = requestData?.get("data") as? Map<*, *>
        val targetPlayerId = data?.get("id") as? String
        val allianceMatchRequest = data?.get("allianceMatchRequest") as? Boolean ?: false

        // When targetPlayerId is null, this is a "Raiding Practice" mode where the player attacks their own compound
        val actualTargetPlayerId = targetPlayerId ?: playerId

        Logger.debug(LogConfigSocketToClient) {
            "PLAYER_ATTACK_REQUEST: Player $playerId attacking $actualTargetPlayerId (allianceMatch=$allianceMatchRequest, practice=${targetPlayerId == null})"
        }

        val targetPlayerObjects = serverContext.db.loadPlayerObjects(actualTargetPlayerId)

        if (targetPlayerObjects == null) {
            val errorResponse = listOf(
                NetworkMessage.SEND_RESPONSE,
                messageId,
                Time.now(),
                """{"status":"error"}"""
            )
            send(PIOSerializer.serialize(errorResponse))
            return
        }

        val buildingsJson = buildString {
            append("[")
            append(targetPlayerObjects.buildings.joinToString(",") { building ->
                buildString {
                    append("{\"id\":\"${building.id}\",")
                    append("\"type\":\"${building.type}\",")
                    append("\"level\":${building.level},")
                    append("\"tx\":${building.tx},")
                    append("\"ty\":${building.ty},")
                    append("\"rotation\":${building.rotation},")
                    append("\"destroyed\":${building.destroyed},")
                    append("\"health\":${building.resourceValue},")
                    append("\"maxHealth\":100")
                    append("}")
                }
            })
            append("]")
        }

        val survivorsJson = buildString {
            append("[")
            append(targetPlayerObjects.survivors.joinToString(",") { survivor ->
                buildString {
                    append("{\"id\":\"${survivor.id}\",")
                    append("\"title\":\"${survivor.title}\",")
                    append("\"firstName\":\"${survivor.firstName}\",")
                    append("\"lastName\":\"${survivor.lastName}\",")
                    append("\"gender\":\"${survivor.gender}\",")
                    append("\"portrait\":${survivor.portrait?.let { "\"$it\"" } ?: "null"},")
                    append("\"classId\":\"${survivor.classId}\",")
                    append("\"level\":${survivor.level},")
                    append("\"xp\":${survivor.xp},")
                    append("\"morale\":{},")
                    append("\"injuries\":[],")
                    append("\"assignmentId\":${survivor.assignmentId?.let { "\"$it\"" } ?: "null"}")
                    append("}")
                }
            })
            append("]")
        }

        val resourcesJson = buildString {
            append("{\"cash\":${targetPlayerObjects.resources.cash},")
            append("\"wood\":${targetPlayerObjects.resources.wood},")
            append("\"metal\":0,")
            append("\"cloth\":0,")
            append("\"food\":${targetPlayerObjects.resources.food},")
            append("\"water\":0,")
            append("\"ammunition\":0}")
        }

        val rallyJson = buildString {
            append("{")
            val assignments = targetPlayerObjects.survivors.filter { it.assignmentId != null }
                .groupBy { it.assignmentId!! }
            append(assignments.entries.joinToString(",") { (buildingId, assignedSurvivors) ->
                val survivorIds = assignedSurvivors.joinToString(",") { "\"${it.id}\"" }
                "\"$buildingId\":[$survivorIds]"
            })
            append("}")
        }

        val responseJson = buildString {
            append("{\"status\":\"success\",")
            append("\"buildings\":$buildingsJson,")
            append("\"survivors\":$survivorsJson,")
            append("\"resources\":$resourcesJson,")
            append("\"rally\":$rallyJson,")
            append("\"loadout\":{},")
            append("\"research\":{},")
            append("\"sameIP\":false,")
            append("\"bounty\":0,")
            append("\"allianceMatch\":false")
            append("}")
        }

        val response = listOf(
            NetworkMessage.SEND_RESPONSE,
            messageId,
            Time.now(),
            responseJson
        )
        send(PIOSerializer.serialize(response))

        Logger.debug(LogConfigSocketToClient) {
            "PLAYER_ATTACK_REQUEST: Sent attack data for $actualTargetPlayerId (${targetPlayerObjects.buildings.size} buildings, ${targetPlayerObjects.survivors.size} survivors, practice=${targetPlayerId == null})"
        }
    }
}
