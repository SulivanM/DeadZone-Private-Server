package core.compound

import core.PlayerService
import core.data.GameDefinition
import core.model.game.data.*
import common.LogConfigSocketError
import common.Logger
import io.ktor.util.date.*
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds

/**
 * Service for managing player compound data including resources and buildings.
 * Handles resource updates, building operations, and storage capacity calculations.
 */
class CompoundService(private val compoundRepository: CompoundRepository) : PlayerService {
    private lateinit var resources: GameResources
    private val buildings = mutableListOf<BuildingLike>()
    private val lastResourceValueUpdated = mutableMapOf<String, Long>()
    private lateinit var playerId: String

    fun getResources() = resources

    fun getBuildings(): List<BuildingLike> = buildings

    fun getStorageLimit(): Int {
        var totalCapacity = 0
        for (bldLike in buildings) {
            val buildingDef = GameDefinition.findBuilding(bldLike.type) ?: continue
            val levelDef = buildingDef.getLevel(bldLike.level) ?: continue
            val capacity = levelDef.production?.capacity ?: levelDef.capacity ?: continue
            totalCapacity += capacity
        }
        // Return at least a base capacity even if no storage buildings
        return if (totalCapacity > 0) totalCapacity else 10000
    }

    fun getIndexOfBuilding(bldId: String): Int {
        val idx = buildings.indexOfFirst { it.id == bldId }
        if (idx == -1) {
            Logger.error(LogConfigSocketError) { "Building bldId=$bldId not found for playerId=$playerId" }
        }
        return idx
    }

    fun getBuilding(bldId: String): BuildingLike? {
        return buildings.find { it.id == bldId }
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
            Logger.error(LogConfigSocketError) { "Error on updateBuilding for playerId=$playerId: ${it.message}" }
        }
        result.onSuccess {
            buildings[idx] = update
        }
        return result
    }

    suspend fun updateAllBuildings(buildings: List<BuildingLike>): Result<Unit> {
        val result = compoundRepository.updateAllBuildings(playerId, buildings)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on updateAllBuildings for playerId=$playerId: ${it.message}" }
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
            Logger.error(LogConfigSocketError) { "Error on createBuilding for playerId=$playerId: ${it.message}" }
        }
        result.onSuccess {
            this.buildings.add(create)
        }
        return result
    }

    suspend fun deleteBuilding(bldId: String): Result<Unit> {
        val result = compoundRepository.deleteBuilding(playerId, bldId)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on deleteBuilding for playerId=$playerId: ${it.message}" }
        }
        result.onSuccess {
            this.buildings.removeIf { it.id == bldId }
        }
        return result
    }


    suspend fun collectBuilding(bldId: String): Result<GameResources> {
        val lastUpdate = lastResourceValueUpdated[bldId]
            ?: return Result.failure(NoSuchElementException("Building bldId=$bldId is not categorized as production buildings"))

        val building = getBuilding(bldId)
            ?: return Result.failure(NoSuchElementException("Building bldId=$bldId not found"))

        val collectedAmount = calculateResource(building.type, building.level, lastUpdate.seconds)
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
            Logger.error(LogConfigSocketError) { "Error on updateResource for playerId=$playerId: ${it.message}" }
        }
        result.onSuccess {
            this.resources = update
        }
        return result
    }

    fun calculateResource(buildingType: String, buildingLevel: Int, durationSec: Duration): Double {
        val buildingDef = GameDefinition.findBuilding(buildingType)
        if (buildingDef == null) {
            Logger.warn { "Building type $buildingType not found in GameDefinition, using default rate" }
            return 10.0 + (4 * durationSec.inWholeMinutes)
        }

        val levelDef = buildingDef.getLevel(buildingLevel)
        if (levelDef == null) {
            Logger.warn { "Building level $buildingLevel not found for type $buildingType, using default rate" }
            return 10.0 + (4 * durationSec.inWholeMinutes)
        }

        val productionRate = levelDef.production?.rate ?: 4.0
        val productionCap = levelDef.production?.cap ?: Int.MAX_VALUE

        val produced = productionRate * durationSec.inWholeMinutes
        return minOf(produced, productionCap.toDouble())
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
                    oldBld.copy(resourceValue = calculateResource(oldBld.type, oldBld.level, (now - lastUpdate).seconds))
                }
                updateResult.onFailure {
                    Logger.error(LogConfigSocketError) { "Failed to update building ${bldLike.id} during close for playerId=$playerId: ${it.message}" }
                }
            }
        }
    }

    private fun isProductionBuilding(idInXML: String): Boolean {
        return idInXML.contains("resource")
    }
}