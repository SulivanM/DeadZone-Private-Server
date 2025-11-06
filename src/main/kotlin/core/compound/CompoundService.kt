package core.compound

import core.PlayerService
import core.model.game.data.*
import utils.LogConfigSocketError
import utils.LogLevel
import utils.Logger
import utils.DataLogger
import io.ktor.util.date.*
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds

class CompoundService(private val compoundRepository: CompoundRepository) : PlayerService {
    private lateinit var resources: GameResources
    private val buildings = mutableListOf<BuildingLike>()
    private val lastResourceValueUpdated = mutableMapOf<String, Long>()
    private lateinit var playerId: String

    fun getResources() = resources

    fun getIndexOfBuilding(bldId: String): Int {
        val idx = buildings.indexOfFirst { it.id == bldId }
        if (idx == -1) {
            DataLogger.event("BuildingNotFound")
                .prefixText("Building not found")
                .playerId(playerId)
                .data("buildingId", bldId)
                .data("operation", "getIndexOfBuilding")
                .record()
                .log(LogLevel.ERROR)
        }
        return idx
    }

    fun getBuilding(bldId: String): BuildingLike? {
        return buildings.find { it.id == bldId }
    }

    fun getAllBuildings(): List<BuildingLike> {
        return buildings.toList()
    }

    suspend fun updateBuilding(
        bldId: String,
        updateAction: suspend (BuildingLike) -> BuildingLike
    ): Result<Unit> {
        val idx = getIndexOfBuilding(bldId)
        if (idx == -1) return Result.failure(NoSuchElementException("Building bldId=$bldId not found for playerId=$playerId"))

        val update = updateAction(buildings[idx])

        val result = compoundRepository.updateBuilding(playerId, bldId, update)
        result.onFailure {
            DataLogger.event("BuildingUpdateError")
                .prefixText("Error updating building")
                .playerId(playerId)
                .data("buildingId", bldId)
                .data("operation", "updateBuilding")
                .data("error", it.message ?: "unknown")
                .record()
                .log(LogLevel.ERROR)
        }
        result.onSuccess {
            buildings[idx] = update
        }
        return result
    }

    suspend fun updateAllBuildings(buildings: List<BuildingLike>): Result<Unit> {
        val result = compoundRepository.updateAllBuildings(playerId, buildings)
        result.onFailure {
            DataLogger.event("BuildingsUpdateError")
                .prefixText("Error updating all buildings")
                .playerId(playerId)
                .data("buildingCount", buildings.size)
                .data("operation", "updateAllBuildings")
                .data("error", it.message ?: "unknown")
                .record()
                .log(LogLevel.ERROR)
        }
        result.onSuccess {
            this.buildings.clear()
            this.buildings.addAll(buildings)
        }
        return result
    }

    suspend fun createBuilding(createAction: suspend () -> (BuildingLike)): Result<Unit> {
        val create = createAction()
        val result = compoundRepository.createBuilding(playerId, create)
        result.onFailure {
            DataLogger.event("BuildingCreateError")
                .prefixText("Error creating building")
                .playerId(playerId)
                .data("buildingId", create.id)
                .data("buildingType", create.type)
                .data("operation", "createBuilding")
                .data("error", it.message ?: "unknown")
                .record()
                .log(LogLevel.ERROR)
        }
        result.onSuccess {
            this.buildings.add(create)
            DataLogger.event("BuildingCreated")
                .prefixText("Building created successfully")
                .playerId(playerId)
                .data("buildingId", create.id)
                .data("buildingType", create.type)
                .record()
                .log(LogLevel.INFO)
        }
        return result
    }

    suspend fun deleteBuilding(bldId: String): Result<Unit> {
        val result = compoundRepository.deleteBuilding(playerId, bldId)
        result.onFailure {
            DataLogger.event("BuildingDeleteError")
                .prefixText("Error deleting building")
                .playerId(playerId)
                .data("buildingId", bldId)
                .data("operation", "deleteBuilding")
                .data("error", it.message ?: "unknown")
                .record()
                .log(LogLevel.ERROR)
        }
        result.onSuccess {
            this.buildings.removeIf { it.id == bldId }
            DataLogger.event("BuildingDeleted")
                .prefixText("Building deleted successfully")
                .playerId(playerId)
                .data("buildingId", bldId)
                .record()
                .log(LogLevel.INFO)
        }
        return result
    }

    suspend fun collectBuilding(bldId: String): Result<GameResources> {
        val lastUpdate = lastResourceValueUpdated[bldId]
            ?: return Result.failure(NoSuchElementException("Building bldId=$bldId is not categorized as production buildings"))

        val collectedAmount = calculateResource(lastUpdate.seconds)
        lastResourceValueUpdated[bldId] = getTimeMillis()

        val updateResult = updateBuilding(bldId) { oldBld ->
            oldBld.copy(resourceValue = 0.0)
        }
        updateResult.onFailure { return Result.failure(it) }

        return Result.success(GameResources(wood = collectedAmount.toInt()))
    }

    suspend fun updateResource(updateAction: suspend (GameResources) -> (GameResources)): Result<Unit> {
        val update = updateAction(this.resources)
        val result = compoundRepository.updateGameResources(playerId, update)
        result.onFailure {
            DataLogger.event("ResourceUpdateError")
                .prefixText("Error updating resources")
                .playerId(playerId)
                .data("operation", "updateResource")
                .data("error", it.message ?: "unknown")
                .record()
                .log(LogLevel.ERROR)
        }
        result.onSuccess {
            this.resources = update
        }
        return result
    }

    fun calculateResource(durationSec: Duration): Double {
        val productionRate = 4
        
        
        return 10.0 + (productionRate * durationSec.inWholeMinutes)
    }

    override suspend fun init(playerId: String): Result<Unit> {
        return runCatching {
            this.playerId = playerId
            val _resources = compoundRepository.getGameResources(playerId).getOrThrow()
            val _buildings = compoundRepository.getBuildings(playerId).getOrThrow()
            this.resources = _resources
            buildings.addAll(_buildings)

            val now = getTimeMillis()

            for (bldLike in buildings) {
                if (isProductionBuilding(bldLike.type)) {
                    lastResourceValueUpdated[bldLike.id] = now
                }
            }
        }
    }

    override suspend fun close(playerId: String): Result<Unit> {
        return runCatching {
            val now = getTimeMillis()

            for (bldLike in buildings) {
                if (bldLike is JunkBuilding) continue
                val lastUpdate = lastResourceValueUpdated[bldLike.id] ?: continue
                val updateResult = updateBuilding(bldLike.id) { oldBld ->
                    oldBld.copy(resourceValue = calculateResource((now - lastUpdate).seconds))
                }
                updateResult.onFailure {
                    DataLogger.event("BuildingCloseError")
                        .prefixText("Failed to update building during close")
                        .playerId(playerId)
                        .data("buildingId", bldLike.id)
                        .data("operation", "close")
                        .data("error", it.message ?: "unknown")
                        .record()
                        .log(LogLevel.ERROR)
                }
            }
        }
    }

    private fun isProductionBuilding(idInXML: String): Boolean {
        return idInXML.contains("resource")
    }
}
