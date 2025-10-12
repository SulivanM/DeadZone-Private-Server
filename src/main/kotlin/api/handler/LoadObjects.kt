package api.handler

import api.message.db.BigDBObject
import api.message.db.LoadObjectsArgs
import api.message.db.LoadObjectsOutput
import api.utils.pioFraming
import context.ServerContext
import data.collection.NeighborHistory
import dev.deadzone.core.LazyDataUpdater
import utils.LogConfigAPIError
import utils.LogConfigSocketToClient
import utils.Logger
import utils.logInput
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf
import utils.logOutput
import kotlin.math.max

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.loadObjects(serverContext: ServerContext) {
    val loadObjectsArgs = ProtoBuf.decodeFromByteArray<LoadObjectsArgs>(
        call.receiveChannel().toByteArray()
    )

    logInput(loadObjectsArgs, disableLogging = true)

    val dbObjects = mutableListOf<BigDBObject>()
    for (objId in loadObjectsArgs.objectIds) {
        val playerId = objId.keys.firstOrNull() ?: continue

        // The game stubbornly retries API 85 with suffixed -<numbers> e.g., -2, -3, -4 infinitely.
        if (playerId.endsWith("-2")) continue

        val result = serverContext.playerAccountRepository.getProfileOfPlayerId(playerId)
        result.onFailure {
            Logger.warn(LogConfigAPIError) { "Failure on getProfileOfPlayerId for playerId=$playerId: ${it.message}" }
            continue
        }

        val profile = requireNotNull(result.getOrThrow()) {
            "getProfileOfPlayerId succeed but returned profile is null"
        }
        val playerObjects = serverContext.db.loadPlayerObjects(playerId)!!
        val neighborHistory = serverContext.db.loadNeighborHistory(playerId)!!
        val inventory = serverContext.db.loadInventory(playerId)!!
        val obj: BigDBObject? = when (objId.table) {
            "PlayerObjects" -> {
                val updatedBuildings = LazyDataUpdater.updateBuildingTimers(playerObjects.buildings)
                val depletedResources = LazyDataUpdater.depleteResources(profile.lastLogin, playerObjects.resources)
                val updatedSurvivors = playerObjects.survivors.map { srv ->
                    srv.copy(
                        lastName = srv.lastName.takeIf { it.isNotEmpty() } ?: "DZ",
                        level = max(srv.level, 1)
                    )
                }

                val updatedPlayerObjects = playerObjects.copy(
                    buildings = updatedBuildings,
                    resources = depletedResources,
                    survivors = updatedSurvivors
                )

                try {
                    serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                } catch (e: Exception) {
                    Logger.error(LogConfigSocketToClient) { "Error while updating time-dynamic data: ${e.message}" }
                    return
                }

                LoadObjectsOutput.fromData(updatedPlayerObjects)
            }

            "NeighborHistory" -> LoadObjectsOutput.fromData(
                NeighborHistory(
                    playerId = playerId,
                    map = neighborHistory.map
                )
            )

            "Inventory" -> LoadObjectsOutput.fromData(inventory)
            else -> {
                Logger.error(LogConfigAPIError) { "UNIMPLEMENTED table for ${objId.table}" }
                null
            }
        }
        if (obj != null) dbObjects.add(obj)
    }

    val loadObjectsOutput = ProtoBuf.encodeToByteArray(LoadObjectsOutput(objects = dbObjects))

    logOutput(loadObjectsOutput, disableLogging = true)

    call.respondBytes(loadObjectsOutput.pioFraming())
}