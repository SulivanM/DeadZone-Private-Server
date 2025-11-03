package server.handler.save.arena

import core.data.GameDefinition
import core.model.game.data.arena.ActiveArenaSession
import core.model.game.data.arena.ActiveArenaStageData
import core.model.game.data.arena.ArenaDefinition
import data.collection.ArenaLeaderboardEntry
import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.broadcast.BroadcastService
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import kotlinx.serialization.json.JsonElement
import utils.JSON
import utils.LogConfigSocketToClient
import utils.Logger
import utils.UUID
import utils.toJsonElement

class ArenaSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.ARENA_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.ARENA_START -> handleArenaStart(ctx)
            SaveDataMethod.ARENA_CONTINUE -> handleArenaContinue(ctx)
            SaveDataMethod.ARENA_FINISH -> handleArenaFinish(ctx)
            SaveDataMethod.ARENA_ABORT -> handleArenaAbort(ctx)
            SaveDataMethod.ARENA_DEATH -> handleArenaDeath(ctx)
            SaveDataMethod.ARENA_UPDATE -> handleArenaUpdate(ctx)
            SaveDataMethod.ARENA_LEADER -> handleArenaLeader(ctx)
            SaveDataMethod.ARENA_LEADERBOARD -> handleArenaLeaderboard(ctx)
        }
    }

    private suspend fun handleArenaStart(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_START: No playerId in connection" }
            sendError("No player ID")
            return
        }

        val arenaName = data["name"] as? String ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_START: Missing 'name' field" }
            sendError("Missing arena name")
            return
        }

        @Suppress("UNCHECKED_CAST")
        val survivorIds = (data["survivors"] as? List<String>) ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_START: Missing or invalid 'survivors' field" }
            sendError("Missing survivors")
            return
        }

        @Suppress("UNCHECKED_CAST")
        val loadouts = (data["loadout"] as? List<Any>) ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_START: Missing or invalid 'loadout' field" }
            sendError("Missing loadout")
            return
        }

        val arenaDefinition = GameDefinition.arenasById[arenaName] ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_START: Arena '$arenaName' not found" }
            sendError("Arena not found")
            return
        }

        if (survivorIds.size < arenaDefinition.survivorMin || survivorIds.size > arenaDefinition.survivorMax) {
            Logger.error(LogConfigSocketToClient) {
                "ARENA_START: Invalid survivor count ${survivorIds.size} (min: ${arenaDefinition.survivorMin}, max: ${arenaDefinition.survivorMax})"
            }
            sendError("Invalid survivor count")
            return
        }

        val sessionId = UUID.new()
        val currentTime = System.currentTimeMillis()

        val stages = arenaDefinition.stages.mapIndexed { index, stageDef ->
            ActiveArenaStageData(
                index = index,
                survivorCount = 0,
                survivorPoints = 0,
                objectivePoints = 0,
                state = if (index == 0) 1 else 0  
            )
        }

        val loadoutStrings = loadouts.map { loadout ->
            when (loadout) {
                is Map<*, *> -> {
                    @Suppress("UNCHECKED_CAST")
                    val loadoutMap = loadout as Map<String, Any?>
                    JSON.encode(loadoutMap.toJsonElement())
                }
                else -> loadout.toString()
            }
        }

        val session = ActiveArenaSession(
            id = sessionId,
            playerId = playerId,
            arenaName = arenaName,
            currentStageIndex = 0,
            completedStageIndex = -1,
            totalPoints = 0,
            survivorIds = survivorIds,
            survivorLoadouts = loadoutStrings,
            survivorHealth = survivorIds.associateWith { 1.0 },  
            stages = stages,
            hasStarted = true,
            isCompleted = false,
            successful = false,
            bailedOut = false,
            createdAt = currentTime,
            lastUpdatedAt = currentTime
        )

        try {
            serverContext.db.saveActiveArenaSession(session)
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) { "ARENA_START: Failed to save session: ${e.message}" }
            sendError("Failed to create session")
            return
        }

        Logger.info(LogConfigSocketToClient) {
            "ARENA_START: Created new arena session $sessionId for player $playerId in arena '$arenaName' with ${survivorIds.size} survivors"
        }

        val missionData = createMissionDataForStage(arenaDefinition, session, 0)

        val response = mapOf(
            "success" to true,
            "id" to sessionId,
            "survivors" to survivorIds,
            "mission" to missionData
        )

        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response.toJsonElement()))))
    }

    private suspend fun handleArenaContinue(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_CONTINUE: No playerId in connection" }
            sendError("No player ID")
            return
        }

        val sessionId = data["id"] as? String ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_CONTINUE: Missing 'id' field" }
            sendError("Missing session ID")
            return
        }

        val session = serverContext.db.getActiveArenaSession(sessionId) ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_CONTINUE: Session $sessionId not found" }
            sendError("Session not found")
            return
        }

        if (session.playerId != playerId) {
            Logger.error(LogConfigSocketToClient) { "ARENA_CONTINUE: Session $sessionId does not belong to player $playerId" }
            sendError("Access denied")
            return
        }

        val arenaDefinition = GameDefinition.arenasById[session.arenaName] ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_CONTINUE: Arena '${session.arenaName}' not found" }
            sendError("Arena not found")
            return
        }

        val missionData = createMissionDataForStage(arenaDefinition, session, session.currentStageIndex)

        Logger.info(LogConfigSocketToClient) {
            "ARENA_CONTINUE: Continuing session $sessionId at stage ${session.currentStageIndex}"
        }

        val response = mapOf(
            "success" to true,
            "mission" to missionData
        )

        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response.toJsonElement()))))
    }

    private suspend fun handleArenaUpdate(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_UPDATE: No playerId in connection" }
            sendError("No player ID")
            return
        }

        @Suppress("UNCHECKED_CAST")
        val hpData = data["hp"] as? Map<String, Any> ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_UPDATE: Missing or invalid 'hp' field" }
            sendError("Missing HP data")
            return
        }

        val sessions = serverContext.db.getActiveArenaSessionsForPlayer(playerId)
        if (sessions.isEmpty()) {
            Logger.warn(LogConfigSocketToClient) { "ARENA_UPDATE: No active sessions for player $playerId" }
            sendSuccess()
            return
        }

        val session = sessions.first()

        val newHealth = hpData.mapValues { (_, value) ->
            when (value) {
                is Number -> value.toDouble()
                else -> 1.0
            }
        }

        val updatedSession = session.copy(
            survivorHealth = newHealth,
            lastUpdatedAt = System.currentTimeMillis()
        )

        try {
            serverContext.db.saveActiveArenaSession(updatedSession)
            Logger.debug(LogConfigSocketToClient) { "ARENA_UPDATE: Updated HP for session ${session.id}" }
            sendSuccess()
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) { "ARENA_UPDATE: Failed to update session: ${e.message}" }
            sendError("Failed to update")
        }
    }

    private suspend fun handleArenaDeath(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_DEATH: No playerId in connection" }
            sendError("No player ID")
            return
        }

        val sessionId = data["id"] as? String
        val survivorId = data["survivor_id"] as? String

        if (sessionId == null && survivorId == null) {
            Logger.warn(LogConfigSocketToClient) { "ARENA_DEATH: No session or survivor ID provided" }
            sendSuccess()
            return
        }

        val session = if (sessionId != null) {
            serverContext.db.getActiveArenaSession(sessionId)
        } else {
            serverContext.db.getActiveArenaSessionsForPlayer(playerId).firstOrNull()
        } ?: run {
            Logger.warn(LogConfigSocketToClient) { "ARENA_DEATH: No active session found" }
            sendSuccess()
            return
        }

        if (session.playerId != playerId) {
            Logger.error(LogConfigSocketToClient) { "ARENA_DEATH: Access denied" }
            sendError("Access denied")
            return
        }

        if (survivorId != null && session.survivorHealth.containsKey(survivorId)) {
            val updatedHealth = session.survivorHealth.toMutableMap()
            updatedHealth[survivorId] = 0.0

            val updatedSession = session.copy(
                survivorHealth = updatedHealth,
                lastUpdatedAt = System.currentTimeMillis()
            )

            serverContext.db.saveActiveArenaSession(updatedSession)
            Logger.info(LogConfigSocketToClient) { "ARENA_DEATH: Marked survivor $survivorId as dead in session ${session.id}" }
        }

        sendSuccess()
    }

    private suspend fun handleArenaFinish(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_FINISH: No playerId in connection" }
            sendError("No player ID")
            return
        }

        val sessionId = data["id"] as? String ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_FINISH: Missing 'id' field" }
            sendError("Missing session ID")
            return
        }

        val session = serverContext.db.getActiveArenaSession(sessionId) ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_FINISH: Session $sessionId not found" }
            sendError("Session not found")
            return
        }

        if (session.playerId != playerId) {
            Logger.error(LogConfigSocketToClient) { "ARENA_FINISH: Access denied" }
            sendError("Access denied")
            return
        }

        val arenaDefinition = GameDefinition.arenasById[session.arenaName] ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_FINISH: Arena '${session.arenaName}' not found" }
            sendError("Arena not found")
            return
        }

        val rewards = calculateRewards(arenaDefinition, session.totalPoints)

        serverContext.db.deleteActiveArenaSession(sessionId)

        Logger.info(LogConfigSocketToClient) {
            "ARENA_FINISH: Finished arena session $sessionId with ${session.totalPoints} points (bailed out)"
        }

        val response = mapOf(
            "success" to true,
            "points" to session.totalPoints,
            "items" to rewards.map { mapOf("type" to it.itemType, "q" to it.quantity) }
        )

        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response.toJsonElement()))))
    }

    private suspend fun handleArenaAbort(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_ABORT: No playerId in connection" }
            sendError("No player ID")
            return
        }

        val sessionId = data["id"] as? String ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_ABORT: Missing 'id' field" }
            sendError("Missing session ID")
            return
        }

        val session = serverContext.db.getActiveArenaSession(sessionId) ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_ABORT: Session $sessionId not found" }
            sendError("Session not found")
            return
        }

        if (session.playerId != playerId) {
            Logger.error(LogConfigSocketToClient) { "ARENA_ABORT: Access denied" }
            sendError("Access denied")
            return
        }

        serverContext.db.deleteActiveArenaSession(sessionId)

        Logger.info(LogConfigSocketToClient) {
            "ARENA_ABORT: Aborted arena session $sessionId at stage ${session.currentStageIndex}"
        }

        val response = mapOf(
            "success" to true
        )

        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response.toJsonElement()))))
    }

    private suspend fun handleArenaLeader(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_LEADER: No playerId in connection" }
            return
        }

        val arenaName = data["name"] as? String ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_LEADER: Missing 'name' field" }
            return
        }

        val level = (data["level"] as? Number)?.toInt() ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_LEADER: Missing or invalid 'level' field" }
            return
        }

        val points = (data["points"] as? Number)?.toInt() ?: 0

        val playerObjects = serverContext.db.loadPlayerObjects(playerId) ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_LEADER: PlayerObjects not found for playerId=$playerId" }
            return
        }

        val playerName = playerObjects.nickname ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_LEADER: Player name not found for playerId=$playerId" }
            return
        }

        val entry = ArenaLeaderboardEntry(
            playerId = playerId,
            playerName = playerName,
            arenaName = arenaName,
            level = level,
            points = points,
            timestamp = System.currentTimeMillis()
        )

        try {
            serverContext.db.saveArenaLeaderboardEntry(entry)
            
            ArenaLeaderboardCache.invalidate(arenaName)
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) { "ARENA_LEADER: Failed to save leaderboard entry: ${e.message}" }
            send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(mapOf("success" to false)))))
            return
        }

        BroadcastService.broadcastArenaLeader(playerName, arenaName, level, points)

        Logger.info(LogConfigSocketToClient) {
            "ARENA_LEADER: Player '$playerName' became leader in arena '$arenaName' (level=$level, points=$points)"
        }

        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(mapOf("success" to true)))))
    }

    private suspend fun handleArenaLeaderboard(ctx: SaveHandlerContext) = with(ctx) {
        val arenaName = data["name"] as? String ?: run {
            Logger.error(LogConfigSocketToClient) { "ARENA_LEADERBOARD: Missing 'name' field" }
            send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(mapOf("success" to false)))))
            return
        }

        val type = data["type"] as? String ?: "weekly"

        Logger.debug(LogConfigSocketToClient) {
            "ARENA_LEADERBOARD: Requesting leaderboard for arena '$arenaName' (type=$type)"
        }

        val leaderboardEntries = ArenaLeaderboardCache.get(arenaName) ?: run {
            try {
                val entries = serverContext.db.getArenaLeaderboard(arenaName, limit = 100)
                ArenaLeaderboardCache.put(arenaName, entries)
                entries
            } catch (e: Exception) {
                Logger.error(LogConfigSocketToClient) { "ARENA_LEADERBOARD: Failed to retrieve leaderboard: ${e.message}" }
                send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(mapOf("success" to false, "error" to "Failed to retrieve leaderboard")))))
                return
            }
        }

        val leaderboardData = leaderboardEntries.mapIndexed { index, entry ->
            index.toString() to mapOf(
                "playerId" to entry.playerId,
                "playerName" to entry.playerName,
                "level" to entry.level,
                "points" to entry.points,
                "timestamp" to entry.timestamp
            )
        }.toMap()

        Logger.info(LogConfigSocketToClient) {
            "ARENA_LEADERBOARD: Returning ${leaderboardEntries.size} entries for arena '$arenaName'"
        }

        val now = System.currentTimeMillis()
        val calendar = java.util.Calendar.getInstance(java.util.TimeZone.getTimeZone("UTC"))
        calendar.timeInMillis = now

        val daysUntilMonday = (9 - calendar.get(java.util.Calendar.DAY_OF_WEEK)) % 7
        calendar.add(java.util.Calendar.DAY_OF_YEAR, if (daysUntilMonday == 0) 7 else daysUntilMonday)
        calendar.set(java.util.Calendar.HOUR_OF_DAY, 0)
        calendar.set(java.util.Calendar.MINUTE, 0)
        calendar.set(java.util.Calendar.SECOND, 0)
        calendar.set(java.util.Calendar.MILLISECOND, 0)

        val resetTime = calendar.timeInMillis

        val response = mapOf(
            "success" to true,
            "data" to leaderboardData,
            "reset" to resetTime
        )

        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response.toJsonElement()))))
    }

    private fun createMissionDataForStage(
        arenaDefinition: ArenaDefinition,
        session: ActiveArenaSession,
        stageIndex: Int
    ): Map<String, Any> {
        val stageDef = arenaDefinition.stages.getOrNull(stageIndex) ?: arenaDefinition.stages.first()

        return mapOf<String, Any>(
            "level" to (14 + stageDef.enemyLevel),  
            "time" to stageDef.time,
            "map" to (stageDef.maps.randomOrNull() ?: ""),
            "assignmentId" to session.id,
            "assignmentType" to "Arena"
        )
    }

    private fun calculateRewards(arenaDefinition: ArenaDefinition, points: Int): List<core.model.game.data.arena.ArenaRewardTier> {
        
        return arenaDefinition.rewards
            .filter { it.score <= points }
            .sortedByDescending { it.score }
            .take(1)
    }

    private suspend fun SaveHandlerContext.sendSuccess() {
        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(mapOf("success" to true)))))
    }

    private suspend fun SaveHandlerContext.sendError(message: String) {
        send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(mapOf("success" to false, "error" to message)))))
    }
}
