package api.handler

import api.message.db.BigDBObject
import api.message.db.LoadObjectsArgs
import api.message.db.LoadObjectsOutput
import api.utils.pioFraming
import context.ServerContext
import core.LazyDataUpdater
import data.collection.NeighborHistory
import utils.LogConfigAPIError
import utils.LogConfigSocketToClient
import utils.LogSource
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
import kotlin.math.max

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.loadObjects(serverContext: ServerContext) {
    val loadObjectsArgs = ProtoBuf.decodeFromByteArray<LoadObjectsArgs>(
        call.receiveChannel().toByteArray()
    )
    logInput(loadObjectsArgs)
    val objs = mutableListOf<BigDBObject>()
    for (objId in loadObjectsArgs.objectIds) {
        val playerId = objId.keys.firstOrNull() ?: continue
        val result = serverContext.playerAccountRepository.getProfileOfPlayerId(playerId)
        result.onFailure {
            Logger.warn(LogConfigAPIError) { "Failure on getProfileOfPlayerId for playerId=$playerId: ${it.message}" }
            continue
        }
        val profile = requireNotNull(result.getOrThrow()) {
            "getProfileOfPlayerId succeed but returned profile is null"
        }
        Logger.debug(src = LogSource.API) { "Found object for playerId: $playerId" }
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
                try {
                    serverContext.db.updatePlayerObjectsField(playerId, "buildings", updatedBuildings)
                    serverContext.db.updatePlayerObjectsField(playerId, "resources", depletedResources)
                    serverContext.db.updatePlayerObjectsField(playerId, "survivors", updatedSurvivors)
                } catch (e: Exception) {
                    Logger.error(LogConfigSocketToClient) { "Error while updating time-dynamic data: ${e.message}" }
                    return
                }
                LoadObjectsOutput.fromData(
                    playerObjects.copy(
                        buildings = updatedBuildings,
                        resources = depletedResources,
                        survivors = updatedSurvivors
                    )
                )
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
        if (obj != null) objs.add(obj)
    }
    val loadObjectsOutput = ProtoBuf.encodeToByteArray(LoadObjectsOutput(objects = objs))
    call.respondBytes(loadObjectsOutput.pioFraming())
}