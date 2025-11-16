package api.handler

import api.message.achievements.*
import api.protocol.pioFraming
import context.ServerContext
import core.data.GameDefinition
import core.quests.QuestSystem
import data.collection.PlayerObjects
import common.Logger
import common.logInput
import common.logOutput
import io.ktor.http.HttpStatusCode
import io.ktor.server.request.receiveChannel
import io.ktor.server.response.respond
import io.ktor.server.response.respondBytes
import io.ktor.server.routing.RoutingContext
import io.ktor.utils.io.toByteArray
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

/**
 * Convert achievement data to client Achievement message format
 */
private fun createAchievementMessage(
    achievementId: String,
    playerObjects: PlayerObjects
): Achievement {
    val achievementDef = GameDefinition.achievementsById[achievementId]
    if (achievementDef == null) {
        return Achievement(
            identifier = achievementId,
            title = "",
            description = "",
            imageUrl = "",
            progressGoal = 100u,
            progress = 0u,
            lastUpdated = System.currentTimeMillis().toDouble()
        )
    }

    // Check quest objectives to get current progress
    val questProgress = QuestSystem.checkQuestObjectives(achievementDef, playerObjects, null)
    
    // For achievements with multiple goals, we take the sum or first goal's progress
    // This matches the client expectation of a single progress value
    val currentProgress = if (questProgress.objectives.isEmpty()) {
        0
    } else {
        questProgress.objectives.values.first().current
    }
    
    val progressGoal = if (achievementDef.goals.isEmpty()) {
        100
    } else {
        achievementDef.goals.first().value
    }

    val imageUrl = achievementDef.startImageUri ?: achievementDef.completeImageUri ?: ""

    return Achievement(
        identifier = achievementId,
        title = "",  // Client has localized strings
        description = "",  // Client has localized strings
        imageUrl = imageUrl,
        progressGoal = progressGoal.toUInt(),
        progress = currentProgress.toUInt(),
        lastUpdated = System.currentTimeMillis().toDouble()
    )
}

/**
 * AchievementsProgressSet handler (277)
 * Sets achievement progress to a specific value
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.achievementsProgressSet(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    logInput(body)

    val args = try {
        ProtoBuf.decodeFromByteArray<AchievementsProgressSetArgs>(body)
    } catch (e: Exception) {
        Logger.error { "Failed to decode AchievementsProgressSetArgs: ${e.message}" }
        val error = AchievementsProgressSetError(1, "Invalid request format")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerToken = call.request.queryParameters["playertoken"]
        ?: call.request.headers["playertoken"]
    
    if (playerToken.isNullOrBlank()) {
        val error = AchievementsProgressSetError(2, "Missing authentication token")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerId = runCatching { serverContext.sessionManager.getPlayerId(playerToken) }.getOrNull()
    if (playerId.isNullOrBlank()) {
        val error = AchievementsProgressSetError(2, "Invalid authentication token")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    // Validate achievement exists
    if (!GameDefinition.achievementsById.containsKey(args.achievementId)) {
        val error = AchievementsProgressSetError(3, "Achievement not found: ${args.achievementId}")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    // Note: This is a client-side progress update endpoint
    // The server currently uses auto-completion based on game state
    // This handler provides the API contract but doesn't modify server state
    // as achievements are automatically completed by the server when goals are met
    
    val playerObjects = serverContext.db.loadPlayerObjects(playerId)
    if (playerObjects == null) {
        val error = AchievementsProgressSetError(4, "Player data not found")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val achievement = createAchievementMessage(args.achievementId, playerObjects)
    val wasCompleted = QuestSystem.isQuestCompleted(args.achievementId, playerObjects)
    
    val output = AchievementsProgressSetOutput(
        achievement = achievement,
        completedNow = false // Server uses auto-completion, not manual progress updates
    )

    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded)
    call.respondBytes(encoded.pioFraming())
}

/**
 * AchievementsProgressAdd handler (280)
 * Adds to achievement progress (delta)
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.achievementsProgressAdd(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    logInput(body)

    val args = try {
        ProtoBuf.decodeFromByteArray<AchievementsProgressAddArgs>(body)
    } catch (e: Exception) {
        Logger.error { "Failed to decode AchievementsProgressAddArgs: ${e.message}" }
        val error = AchievementsProgressAddError(1, "Invalid request format")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerToken = call.request.queryParameters["playertoken"]
        ?: call.request.headers["playertoken"]
    
    if (playerToken.isNullOrBlank()) {
        val error = AchievementsProgressAddError(2, "Missing authentication token")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerId = runCatching { serverContext.sessionManager.getPlayerId(playerToken) }.getOrNull()
    if (playerId.isNullOrBlank()) {
        val error = AchievementsProgressAddError(2, "Invalid authentication token")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    // Validate achievement exists
    if (!GameDefinition.achievementsById.containsKey(args.achievementId)) {
        val error = AchievementsProgressAddError(3, "Achievement not found: ${args.achievementId}")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerObjects = serverContext.db.loadPlayerObjects(playerId)
    if (playerObjects == null) {
        val error = AchievementsProgressAddError(4, "Player data not found")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val achievement = createAchievementMessage(args.achievementId, playerObjects)
    
    val output = AchievementsProgressAddOutput(
        achievement = achievement,
        completedNow = false // Server uses auto-completion
    )

    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded)
    call.respondBytes(encoded.pioFraming())
}

/**
 * AchievementsProgressMax handler (283)
 * Sets achievement progress to max of current or new value
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.achievementsProgressMax(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    logInput(body)

    val args = try {
        ProtoBuf.decodeFromByteArray<AchievementsProgressMaxArgs>(body)
    } catch (e: Exception) {
        Logger.error { "Failed to decode AchievementsProgressMaxArgs: ${e.message}" }
        val error = AchievementsProgressMaxError(1, "Invalid request format")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerToken = call.request.queryParameters["playertoken"]
        ?: call.request.headers["playertoken"]
    
    if (playerToken.isNullOrBlank()) {
        val error = AchievementsProgressMaxError(2, "Missing authentication token")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerId = runCatching { serverContext.sessionManager.getPlayerId(playerToken) }.getOrNull()
    if (playerId.isNullOrBlank()) {
        val error = AchievementsProgressMaxError(2, "Invalid authentication token")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    // Validate achievement exists
    if (!GameDefinition.achievementsById.containsKey(args.achievementId)) {
        val error = AchievementsProgressMaxError(3, "Achievement not found: ${args.achievementId}")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerObjects = serverContext.db.loadPlayerObjects(playerId)
    if (playerObjects == null) {
        val error = AchievementsProgressMaxError(4, "Player data not found")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val achievement = createAchievementMessage(args.achievementId, playerObjects)
    
    val output = AchievementsProgressMaxOutput(
        achievement = achievement,
        completedNow = false // Server uses auto-completion
    )

    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded)
    call.respondBytes(encoded.pioFraming())
}

/**
 * AchievementsProgressComplete handler (286)
 * Manually completes an achievement
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.achievementsProgressComplete(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    logInput(body)

    val args = try {
        ProtoBuf.decodeFromByteArray<AchievementsProgressCompleteArgs>(body)
    } catch (e: Exception) {
        Logger.error { "Failed to decode AchievementsProgressCompleteArgs: ${e.message}" }
        val error = AchievementsProgressCompleteError(1, "Invalid request format")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerToken = call.request.queryParameters["playertoken"]
        ?: call.request.headers["playertoken"]
    
    if (playerToken.isNullOrBlank()) {
        val error = AchievementsProgressCompleteError(2, "Missing authentication token")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerId = runCatching { serverContext.sessionManager.getPlayerId(playerToken) }.getOrNull()
    if (playerId.isNullOrBlank()) {
        val error = AchievementsProgressCompleteError(2, "Invalid authentication token")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    // Validate achievement exists
    if (!GameDefinition.achievementsById.containsKey(args.achievementId)) {
        val error = AchievementsProgressCompleteError(3, "Achievement not found: ${args.achievementId}")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val playerObjects = serverContext.db.loadPlayerObjects(playerId)
    if (playerObjects == null) {
        val error = AchievementsProgressCompleteError(4, "Player data not found")
        val encoded = ProtoBuf.encodeToByteArray(error)
        call.respondBytes(encoded.pioFraming())
        return
    }

    val wasAlreadyCompleted = QuestSystem.isQuestCompleted(args.achievementId, playerObjects)
    val achievement = createAchievementMessage(args.achievementId, playerObjects)
    
    val output = AchievementsProgressCompleteOutput(
        achievement = achievement,
        completedNow = !wasAlreadyCompleted // Report if newly completed
    )

    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded)
    call.respondBytes(encoded.pioFraming())
}
