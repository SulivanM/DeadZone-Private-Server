package server.handler.save.arena

import context.requirePlayerContext
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import common.JSON
import common.LogConfigSocketToClient
import common.Logger
import common.UUID

class ArenaSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.ARENA_SAVES

    // Track active arena sessions
    // Maps sessionId to (playerId, currentStage, points, completedStages)
    private val activeSessions = mutableMapOf<String, ArenaSessionData>()

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId

        when (type) {
            SaveDataMethod.ARENA_START -> {
                Logger.info(LogConfigSocketToClient) { "ARENA_START: Starting new arena session for playerId=$playerId" }

                val arenaName = data["name"] as? String ?: run {
                    Logger.error(LogConfigSocketToClient) { "ARENA_START: Missing 'name' parameter" }
                    sendErrorResponse("Missing arena name")
                    return
                }

                val survivorsList = data["survivors"] as? List<*> ?: run {
                    Logger.error(LogConfigSocketToClient) { "ARENA_START: Missing 'survivors' parameter" }
                    sendErrorResponse("Missing survivors")
                    return
                }

                val loadoutsList = data["loadout"] as? List<*> ?: run {
                    Logger.error(LogConfigSocketToClient) { "ARENA_START: Missing 'loadout' parameter" }
                    sendErrorResponse("Missing loadout")
                    return
                }

                val survivorIds = survivorsList.mapNotNull { it as? String }

                if (survivorIds.isEmpty()) {
                    Logger.error(LogConfigSocketToClient) { "ARENA_START: No valid survivors provided" }
                    sendErrorResponse("No survivors")
                    return
                }

                // Create a unique session ID
                val sessionId = UUID.new()

                // Create session data
                val sessionData = ArenaSessionData(
                    sessionId = sessionId,
                    playerId = playerId,
                    arenaName = arenaName,
                    survivorIds = survivorIds,
                    currentStage = 0,
                    points = 0,
                    completedStages = 0,
                    isCompleted = false
                )

                activeSessions[sessionId] = sessionData

                Logger.info(LogConfigSocketToClient) { "ARENA_START: Created arena session $sessionId for playerId=$playerId with ${survivorIds.size} survivors" }

                // Create mission data for the first stage
                // Arena missions are typically at player level + some scaling
                val services = serverContext.requirePlayerContext(playerId).services
                val leader = services.survivor.getSurvivorLeader()
                val missionLevel = leader.level + 1

                val missionData = mapOf(
                    "level" to missionLevel,
                    "areaType" to "arena",
                    "automated" to false
                )

                // Return success response matching AS3 client expectations
                val response = mapOf(
                    "success" to true,
                    "id" to sessionId,
                    "survivors" to survivorIds,
                    "mission" to missionData
                )

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ARENA_CONTINUE -> {
                Logger.info(LogConfigSocketToClient) { "ARENA_CONTINUE: Continuing arena session for playerId=$playerId" }

                val sessionId = data["id"] as? String ?: run {
                    Logger.error(LogConfigSocketToClient) { "ARENA_CONTINUE: Missing 'id' parameter" }
                    sendErrorResponse("Missing session ID")
                    return
                }

                val sessionData = activeSessions[sessionId]
                if (sessionData == null) {
                    Logger.error(LogConfigSocketToClient) { "ARENA_CONTINUE: Session $sessionId not found" }
                    sendErrorResponse("Session not found")
                    return
                }

                if (sessionData.playerId != playerId) {
                    Logger.error(LogConfigSocketToClient) { "ARENA_CONTINUE: Session $sessionId does not belong to playerId=$playerId" }
                    sendErrorResponse("Invalid session")
                    return
                }

                // Advance to next stage
                val newStage = sessionData.currentStage + 1
                activeSessions[sessionId] = sessionData.copy(currentStage = newStage)

                Logger.info(LogConfigSocketToClient) { "ARENA_CONTINUE: Advanced session $sessionId to stage $newStage" }

                // Create mission data for the next stage
                val services = serverContext.requirePlayerContext(playerId).services
                val leader = services.survivor.getSurvivorLeader()
                val missionLevel = leader.level + newStage + 1

                val missionData = mapOf(
                    "level" to missionLevel,
                    "areaType" to "arena",
                    "automated" to false
                )

                val response = mapOf(
                    "success" to true,
                    "mission" to missionData
                )

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ARENA_FINISH -> {
                Logger.info(LogConfigSocketToClient) { "ARENA_FINISH: Finishing arena session for playerId=$playerId (bail out)" }

                val sessionId = data["id"] as? String ?: run {
                    Logger.error(LogConfigSocketToClient) { "ARENA_FINISH: Missing 'id' parameter" }
                    sendErrorResponse("Missing session ID")
                    return
                }

                val sessionData = activeSessions[sessionId]
                if (sessionData == null) {
                    Logger.error(LogConfigSocketToClient) { "ARENA_FINISH: Session $sessionId not found" }
                    sendErrorResponse("Session not found")
                    return
                }

                if (sessionData.playerId != playerId) {
                    Logger.error(LogConfigSocketToClient) { "ARENA_FINISH: Session $sessionId does not belong to playerId=$playerId" }
                    sendErrorResponse("Invalid session")
                    return
                }

                // Calculate partial rewards based on completed stages
                val points = sessionData.points
                val items = emptyList<Map<String, Any>>() // No items for partial completion

                // Remove session from active sessions
                activeSessions.remove(sessionId)

                Logger.info(LogConfigSocketToClient) { "ARENA_FINISH: Finished session $sessionId with $points points (bail out)" }

                val response = mapOf(
                    "success" to true,
                    "points" to points,
                    "items" to items,
                    "cooldown" to null
                )

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ARENA_ABORT -> {
                Logger.info(LogConfigSocketToClient) { "ARENA_ABORT: Aborting arena session for playerId=$playerId" }

                val sessionId = data["id"] as? String ?: run {
                    Logger.error(LogConfigSocketToClient) { "ARENA_ABORT: Missing 'id' parameter" }
                    sendErrorResponse("Missing session ID")
                    return
                }

                val sessionData = activeSessions[sessionId]
                if (sessionData == null) {
                    Logger.error(LogConfigSocketToClient) { "ARENA_ABORT: Session $sessionId not found" }
                    sendErrorResponse("Session not found")
                    return
                }

                if (sessionData.playerId != playerId) {
                    Logger.error(LogConfigSocketToClient) { "ARENA_ABORT: Session $sessionId does not belong to playerId=$playerId" }
                    sendErrorResponse("Invalid session")
                    return
                }

                // Remove session from active sessions (no rewards)
                activeSessions.remove(sessionId)

                Logger.info(LogConfigSocketToClient) { "ARENA_ABORT: Aborted session $sessionId" }

                val response = mapOf(
                    "success" to true,
                    "cooldown" to null
                )

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ARENA_DEATH -> {
                Logger.info(LogConfigSocketToClient) { "ARENA_DEATH: Handling arena death for playerId=$playerId" }

                // When a survivor dies during arena, the session ends
                val sessionId = data["id"] as? String ?: run {
                    Logger.error(LogConfigSocketToClient) { "ARENA_DEATH: Missing 'id' parameter" }
                    sendErrorResponse("Missing session ID")
                    return
                }

                val sessionData = activeSessions[sessionId]
                if (sessionData == null) {
                    Logger.error(LogConfigSocketToClient) { "ARENA_DEATH: Session $sessionId not found" }
                    sendErrorResponse("Session not found")
                    return
                }

                // Remove session from active sessions (session failed)
                activeSessions.remove(sessionId)

                Logger.info(LogConfigSocketToClient) { "ARENA_DEATH: Session $sessionId ended due to survivor death" }

                val response = mapOf(
                    "success" to true,
                    "points" to 0,
                    "items" to emptyList<Map<String, Any>>()
                )

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ARENA_UPDATE -> {
                Logger.info(LogConfigSocketToClient) { "ARENA_UPDATE: Updating arena state for playerId=$playerId" }

                // Client sends HP updates for survivors during arena mission
                // Format: {hp: {survivorId: 0.75, survivorId2: 0.5, ...}}
                val hpData = data["hp"] as? Map<*, *>
                if (hpData != null) {
                    Logger.debug(LogConfigSocketToClient) { "ARENA_UPDATE: Received HP data for ${hpData.size} survivors" }
                }

                // No response needed for ARENA_UPDATE (void operation)
            }

            SaveDataMethod.ARENA_LEADER -> {
                Logger.info(LogConfigSocketToClient) { "ARENA_LEADER: Getting arena leader for playerId=$playerId" }

                // Return current leader (placeholder - would need leaderboard system)
                val response = mapOf(
                    "success" to true,
                    "leader" to mapOf(
                        "name" to "TopPlayer",
                        "points" to 10000,
                        "rank" to 1
                    )
                )

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.ARENA_LEADERBOARD -> {
                Logger.info(LogConfigSocketToClient) { "ARENA_LEADERBOARD: Getting arena leaderboard for playerId=$playerId" }

                // Return leaderboard (placeholder - would need leaderboard system)
                val leaderboard = listOf(
                    mapOf("rank" to 1, "name" to "Player1", "points" to 10000),
                    mapOf("rank" to 2, "name" to "Player2", "points" to 9000),
                    mapOf("rank" to 3, "name" to "Player3", "points" to 8000)
                )

                val response = mapOf(
                    "success" to true,
                    "leaderboard" to leaderboard
                )

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }
        }
    }

    private suspend fun SaveHandlerContext.sendErrorResponse(error: String) {
        val response = mapOf(
            "success" to false,
            "error" to error
        )
        val responseJson = JSON.encode(response)
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }
}

// Data class to track arena session state
private data class ArenaSessionData(
    val sessionId: String,
    val playerId: String,
    val arenaName: String,
    val survivorIds: List<String>,
    val currentStage: Int,
    val points: Int,
    val completedStages: Int,
    val isCompleted: Boolean
)
