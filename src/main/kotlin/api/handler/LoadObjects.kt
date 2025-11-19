package api.handler

import api.message.db.BigDBObject
import api.message.db.LoadObjectsArgs
import api.message.db.LoadObjectsOutput
import api.protocol.pioFraming
import context.ServerContext
import context.getPlayerContextOrNull
import data.collection.NeighborHistory
import dev.deadzone.core.LazyDataUpdater
import common.LogConfigAPIError
import common.LogConfigSocketToClient
import common.Logger
import common.logInput
import common.logOutput
import io.ktor.http.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf
import kotlin.math.max

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.loadObjects(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val loadObjectsArgs = try {
        ProtoBuf.decodeFromByteArray<LoadObjectsArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(loadObjectsArgs, disableLogging = true)

    val dbObjects = mutableListOf<BigDBObject>()

    try {
        for (objId in loadObjectsArgs.objectIds) {
            val playerId = objId.keys.firstOrNull() ?: continue
            if (playerId.endsWith("-2")) continue

            val profile = serverContext.playerAccountRepository.getProfileOfPlayerId(playerId).getOrNull() ?: continue
            val lastLogin = profile.lastLogin

            val playerObjects = serverContext.db.loadPlayerObjects(playerId) ?: continue
            val neighborHistory = serverContext.db.loadNeighborHistory(playerId)
            val inventory = serverContext.db.loadInventory(playerId)

            val obj: BigDBObject? = try {
                when (objId.table) {
                    "PlayerObjects" -> {
                        val updatedBuildings = LazyDataUpdater.removeBuildingTimerIfDone(playerObjects.buildings)
                        val updatedResources = LazyDataUpdater.depleteResources(lastLogin, playerObjects.resources)
                        val updatedSurvivors = playerObjects.survivors

                        val ctx = serverContext.getPlayerContextOrNull(playerId)
                        if (ctx != null) {
                            runCatching { ctx.services.compound.updateAllBuildings(updatedBuildings) }
                                .onFailure { Logger.warn { "Failed to update buildings for $playerId: ${it.message}" } }
                            runCatching { ctx.services.compound.updateResource { updatedResources } }
                                .onFailure { Logger.warn { "Failed to update resources for $playerId: ${it.message}" } }
                            runCatching { ctx.services.survivor.updateSurvivors(updatedSurvivors) }
                                .onFailure { Logger.warn { "Failed to update survivors for $playerId: ${it.message}" } }
                        } else {
                            runCatching {
                                val updatedPlayerObjects = playerObjects.copy(
                                    buildings = updatedBuildings,
                                    resources = updatedResources,
                                    survivors = updatedSurvivors
                                )
                                serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                            }.onFailure {
                                Logger.error(LogConfigSocketToClient) { "Failed to persist updates for $playerId: ${it.message}" }
                            }
                        }

                        LoadObjectsOutput.fromData(
                            playerObjects.copy(
                                buildings = updatedBuildings,
                                resources = updatedResources,
                                survivors = updatedSurvivors
                            )
                        )
                    }

                    "NeighborHistory" -> neighborHistory?.let {
                        LoadObjectsOutput.fromData(NeighborHistory(playerId = playerId, map = it.map))
                    }

                    "Inventory" -> inventory?.let { LoadObjectsOutput.fromData(it) }

                    else -> {
                        Logger.error(LogConfigAPIError) { "Unimplemented table for ${objId.table}" }
                        null
                    }
                }
            } catch (e: Exception) {
                Logger.error(LogConfigAPIError) { "Error processing ${objId.table} for $playerId: ${e.message}" }
                null
            }

            if (obj != null) dbObjects.add(obj)
        }
    } catch (e: Exception) {
        Logger.error(LogConfigAPIError) { "Critical error in loadObjects: ${e.message}" }
        e.printStackTrace()
    }

    val encoded = ProtoBuf.encodeToByteArray(LoadObjectsOutput(objects = dbObjects))
    logOutput(encoded, disableLogging = true)
    call.respondBytes(encoded.pioFraming())
}