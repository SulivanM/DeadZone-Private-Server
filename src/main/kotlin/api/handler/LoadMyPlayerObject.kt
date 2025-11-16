package api.handler

import api.message.db.LoadObjectsOutput
import api.protocol.pioFraming
import context.ServerContext
import dev.deadzone.core.LazyDataUpdater
import common.LogConfigAPIError
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
import kotlinx.serialization.protobuf.ProtoBuf
import kotlinx.serialization.encodeToByteArray

/**
 * Load the current player's PlayerObject
 * Endpoint 103
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.loadMyPlayerObject(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    logInput("LoadMyPlayerObject", disableLogging = true)

    // Get player ID from authentication token
    val playerId = getPlayerIdFromToken(serverContext)

    if (playerId == null) {
        Logger.error(LogConfigAPIError) { "LoadMyPlayerObject: Could not extract playerId from token" }
        call.respond(HttpStatusCode.Unauthorized, "Invalid or missing token")
        return
    }

    // Load player's PlayerObjects
    val playerObjects = serverContext.db.loadPlayerObjects(playerId)

    if (playerObjects == null) {
        Logger.error(LogConfigAPIError) { "LoadMyPlayerObject: PlayerObjects not found for $playerId" }
        // Return empty list instead of error
        val output = LoadObjectsOutput(objects = emptyList())
        val encoded = ProtoBuf.encodeToByteArray(output)
        logOutput(encoded, disableLogging = true)
        call.respondBytes(encoded.pioFraming())
        return
    }

    // Get last login for lazy updates
    val profile = serverContext.playerAccountRepository.getProfileOfPlayerId(playerId).getOrNull()
    val lastLogin = profile?.lastLogin ?: System.currentTimeMillis()

    // Apply lazy updates
    val updatedBuildings = LazyDataUpdater.removeBuildingTimerIfDone(playerObjects.buildings)
    val updatedResources = LazyDataUpdater.depleteResources(lastLogin, playerObjects.resources)
    val updatedPlayerObjects = playerObjects.copy(
        buildings = updatedBuildings,
        resources = updatedResources
    )

    // Convert to BigDBObject and return
    val dbObject = LoadObjectsOutput.fromData(updatedPlayerObjects)
    val output = LoadObjectsOutput(objects = listOf(dbObject))

    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = true)
    call.respondBytes(encoded.pioFraming())
}
