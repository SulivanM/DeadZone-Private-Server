package server.handler.save.alliance

import context.requirePlayerContext
import data.collection.Alliance
import data.collection.AllianceMember
import dev.deadzone.socket.handler.save.SaveHandlerContext
import io.ktor.util.date.getTimeMillis
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import utils.JSON
import utils.LogConfigSocketToClient
import utils.Logger
import utils.toJsonElement
import utils.UUID

class AllianceSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.ALLIANCE_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.ALLIANCE_CREATE -> {
                Logger.info(LogConfigSocketToClient) { "ALLIANCE_CREATE request received" }

                val allianceName = data["name"] as? String
                val allianceTag = data["tag"] as? String
                val bannerBytes = data["bannerBytes"] as? String
                val thumbImage = data["thumbImage"] as? String

                val allianceId = (data["allianceId"] as? String)?.takeIf { it.isNotBlank() } ?: UUID.new()

                Logger.info(LogConfigSocketToClient) { "Creating alliance '$allianceName' with tag '$allianceTag' and ID $allianceId" }

                serverContext.allianceCreationTracker.trackCreation(connection.playerId, allianceId)

                val alliance = Alliance(
                    allianceId = allianceId,
                    name = allianceName ?: "",
                    tag = allianceTag ?: "",
                    bannerBytes = bannerBytes,
                    thumbImage = thumbImage,
                    createdAt = getTimeMillis(),
                    createdBy = connection.playerId,
                    memberCount = 1
                )
                serverContext.db.createAlliance(alliance)
                Logger.info(LogConfigSocketToClient) { "Created alliance in dedicated table" }

                val member = AllianceMember(
                    allianceId = allianceId,
                    playerId = connection.playerId,
                    joinedAt = getTimeMillis(),
                    rank = 0, 
                    lifetimeStats = core.model.game.data.alliance.AllianceLifetimeStats()
                )
                serverContext.db.addAllianceMember(member)
                Logger.info(LogConfigSocketToClient) { "Added creator as alliance member" }

                val playerObjects = serverContext.db.loadPlayerObjects(connection.playerId)
                if (playerObjects != null) {
                    val updatedPlayerObjects = playerObjects.copy(
                        allianceId = allianceId,
                        allianceTag = allianceTag
                    )
                    serverContext.db.updatePlayerObjectsJson(connection.playerId, updatedPlayerObjects)
                    Logger.info(LogConfigSocketToClient) { "Saved alliance membership reference for player ${connection.playerId}" }
                }

                val response = mapOf(
                    "success" to true,
                    "allianceId" to allianceId,
                    "name" to allianceName,
                    "tag" to allianceTag,
                    "thumbImage" to thumbImage,
                    "bannerBytes" to bannerBytes
                )

                val responseJson = JSON.encode(response.toJsonElement())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ALLIANCE_COLLECT_WINNINGS -> {
                Logger.info(LogConfigSocketToClient) { "ALLIANCE_COLLECT_WINNINGS request received" }

                val response = mapOf(
                    "success" to true,
                    "collected" to false,
                    "rewards" to emptyList<Any>(),
                    "message" to "No winnings available"
                )

                val responseJson = JSON.encode(response.toJsonElement())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ALLIANCE_QUERY_WINNINGS -> {
                Logger.info(LogConfigSocketToClient) { "ALLIANCE_QUERY_WINNINGS request received" }

                val response = mapOf(
                    "available" to false,
                    "winnings" to emptyList<Any>(),
                    "message" to "No winnings to query"
                )

                val responseJson = JSON.encode(response.toJsonElement())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ALLIANCE_GET_PREV_ROUND_RESULT -> {
                Logger.info(LogConfigSocketToClient) { "ALLIANCE_GET_PREV_ROUND_RESULT request received" }

                val response = mapOf(
                    "available" to false,
                    "list" to emptyList<Any>(),
                    "message" to "No previous round data available"
                )

                val responseJson = JSON.encode(response.toJsonElement())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ALLIANCE_EFFECT_UPDATE -> {
                Logger.info(LogConfigSocketToClient) { "ALLIANCE_EFFECT_UPDATE request received" }

                val allianceId = data["id"] as? String
                Logger.debug { "Alliance effect update for allianceId=$allianceId" }

                val response = mapOf(
                    "success" to true,
                    "allianceId" to allianceId,
                    "effects" to emptyList<Any>(),
                    "message" to "Alliance effects updated"
                )

                val responseJson = JSON.encode(response.toJsonElement())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ALLIANCE_INFORM_ABOUT_LEAVE -> {
                Logger.info(LogConfigSocketToClient) { "ALLIANCE_INFORM_ABOUT_LEAVE request received" }

                val allianceId = data["allianceId"] as? String

                Logger.info { "Player ${connection.playerId} left alliance $allianceId" }

                serverContext.db.removeAllianceMember(connection.playerId)
                Logger.info(LogConfigSocketToClient) { "Removed player ${connection.playerId} from alliance members table" }

                if (allianceId != null) {
                    val alliance = serverContext.db.getAlliance(allianceId)
                    if (alliance != null) {
                        val updatedAlliance = alliance.copy(memberCount = alliance.memberCount - 1)
                        serverContext.db.updateAlliance(updatedAlliance)
                        Logger.info(LogConfigSocketToClient) { "Decremented alliance member count" }
                    }
                }

                val playerObjects = serverContext.db.loadPlayerObjects(connection.playerId)
                if (playerObjects != null) {
                    val updatedPlayerObjects = playerObjects.copy(
                        allianceId = null,
                        allianceTag = null
                    )
                    serverContext.db.updatePlayerObjectsJson(connection.playerId, updatedPlayerObjects)
                    Logger.info(LogConfigSocketToClient) { "Cleared alliance membership reference for player ${connection.playerId}" }
                }

                val response = mapOf(
                    "success" to true,
                    "message" to "Alliance leave acknowledged"
                )

                val responseJson = JSON.encode(response.toJsonElement())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ALLIANCE_GET_LIFETIMESTATS -> {
                Logger.info(LogConfigSocketToClient) { "ALLIANCE_GET_LIFETIMESTATS request received" }

                val membership = serverContext.db.getPlayerAllianceMembership(connection.playerId)
                val stats = membership?.lifetimeStats

                val response = mapOf(
                    "available" to true,
                    "totalPoints" to (stats?.points ?: 0),
                    "totalMissions" to (stats?.missionSuccess ?: 0),
                    "totalKills" to (stats?.kills ?: 0),
                    "totalDeaths" to (stats?.deaths ?: 0),
                    "roundsParticipated" to (stats?.roundsParticipated ?: 0),
                    "tokensEarned" to (stats?.tokensEarned ?: 0),
                    "tasksCompleted" to (stats?.tasksCompleted ?: 0),
                    "highestRank" to (stats?.highestRank ?: 0),
                    "message" to "Lifetime stats retrieved"
                )

                val responseJson = JSON.encode(response.toJsonElement())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            else -> {
                Logger.warn(LogConfigSocketToClient) { "Unhandled alliance save type: $type" }
            }
        }
    }
}
