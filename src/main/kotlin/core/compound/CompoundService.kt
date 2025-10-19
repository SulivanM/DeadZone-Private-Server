package core.compound

import core.PlayerService
import core.model.game.data.*
import utils.LogConfigSocketError
import utils.Logger
import io.ktor.util.date.*
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds

class CompoundService(private val compoundRepository: CompoundRepository) : PlayerService {
    private lateinit var resources: GameResources
    private val buildings = mutableListOf<BuildingLike>()
    private val lastResourceValueUpdated = mutableMapOf<String, Long>()
    private lateinit var playerId: String

    fun getResources() = resources

    fun getIndexOfBuilding(bldId: String): Result<Int> {
        val idx = buildings.indexOfFirst { it.id == bldId }
        return if (idx == -1) {
            Logger.error(LogConfigSocketError) { "Building bldId=$bldId not found for playerId=$playerId" }
            Result.failure(NoSuchElementException("Building bldId=$bldId not found for playerId=$playerId"))
        } else {
            Result.success(idx)
        }
    }

    fun getBuilding(bldId: String): BuildingLike? {
        return buildings.find { it.id == bldId }
    }

    suspend fun updateBuilding(
        bldId: String,
        updateAction: suspend (BuildingLike) -> BuildingLike
    ): Result<Unit> {
        return try {
            val idxResult = getIndexOfBuilding(bldId)
            var idx: Int? = null
            idxResult.onSuccess { index ->
                idx = index
            }
            idxResult.onFailure { return Result.failure(it) }
            val update = updateAction(buildings[idx!!])
            val result = compoundRepository.updateBuilding(playerId, bldId, update)
            result.onFailure {
                Logger.error(LogConfigSocketError) { "Error on updateBuilding: ${it.message}" }
            }
            result.onSuccess {
                buildings[idx] = update
            }
            result
        } catch (e: Exception) {
            Logger.error(LogConfigSocketError) { "Failed to update building bldId=$bldId for playerId=$playerId: ${e.message}" }
            Result.failure(e)
        }
    }

    suspend fun updateAllBuildings(buildings: List<BuildingLike>): Result<Unit> {
        return try {
            val result = compoundRepository.updateAllBuildings(playerId, buildings)
            result.onFailure {
                Logger.error(LogConfigSocketError) { "Error on updateAllBuildings: ${it.message}" }
            }
            result.onSuccess {
                this.buildings.clear()
                this.buildings.addAll(buildings)
            }
            result
        } catch (e: Exception) {
            Logger.error(LogConfigSocketError) { "Failed to update all buildings for playerId=$playerId: ${e.message}" }
            Result.failure(e)
        }
    }

    suspend fun createBuilding(createAction: suspend () -> (BuildingLike)) {
        val create = createAction()
        val result = compoundRepository.createBuilding(playerId, create)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on createBuilding: ${it.message}" }
        }
        result.onSuccess {
            this.buildings.add(create)
        }
    }

    suspend fun deleteBuilding(bldId: String): Result<Unit> {
        return try {
            val result = compoundRepository.deleteBuilding(playerId, bldId)
            result.onFailure {
                Logger.error(LogConfigSocketError) { "Error on deleteBuilding: ${it.message}" }
            }
            result.onSuccess {
                this.buildings.removeIf { it.id == bldId }
            }
            result
        } catch (e: Exception) {
            Logger.error(LogConfigSocketError) { "Failed to delete building bldId=$bldId for playerId=$playerId: ${e.message}" }
            Result.failure(e)
        }
    }

    suspend fun cancelBuilding(bldId: String) {
        val result = compoundRepository.deleteBuilding(playerId, bldId)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on cancelBuilding: ${it.message}" }
        }
        result.onSuccess {
            buildings.removeIf { it.id == bldId }
        }
    }

    suspend fun collectBuilding(bldId: String): Result<GameResources> {
        return try {
            val lastUpdate = lastResourceValueUpdated[bldId]
                ?: return Result.failure(NoSuchElementException("Building bldId=$bldId is not categorized as production buildings"))

            val collectedAmount = calculateResource(lastUpdate.seconds)
            lastResourceValueUpdated[bldId] = getTimeMillis()

            lateinit var prod: String
            val updateResult = updateBuilding(bldId) { oldBld ->
                prod = "wood" // Lookup to GameDefinitions, what does the building produce in 'prod' element
                oldBld.copy(resourceValue = 0.0)
            }
            updateResult.onFailure { return Result.failure(it) }

            val res = when (prod) {
                "wood" -> GameResources(wood = collectedAmount.toInt())
                "metal" -> GameResources(metal = collectedAmount.toInt())
                "cloth" -> GameResources(cloth = collectedAmount.toInt())
                "food" -> GameResources(food = collectedAmount.toInt())
                "water" -> GameResources(water = collectedAmount.toInt())
                "cash" -> GameResources(cash = collectedAmount.toInt())
                "ammunition" -> GameResources(ammunition = collectedAmount.toInt())
                else -> {
                    return Result.failure(IllegalArgumentException("Error during collectBuilding, type $prod doesn't exist"))
                }
            }
            Result.success(res)
        } catch (e: Exception) {
            Logger.error(LogConfigSocketError) { "Failed to collect building bldId=$bldId for playerId=$playerId: ${e.message}" }
            Result.failure(e)
        }
    }

    suspend fun updateResource(updateAction: suspend (GameResources) -> (GameResources)) {
        val update = updateAction(this.resources)
        val result = compoundRepository.updateGameResources(playerId, update)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on updateResource: ${it.message}" }
        }
        result.onSuccess {
            this.resources = update
        }
    }

    fun calculateResource(durationSec: Duration): Double {
        val productionRate = 4
        // Parameter: building level, effects
        // See GameDefinitions of building.xml for realistic result
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
            Result.success(Unit)
        }.getOrElse { e ->
            Logger.error(LogConfigSocketError) { "Failed to initialize CompoundService for playerId=$playerId: ${e.message}" }
            Result.failure(e)
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
                    Logger.error(LogConfigSocketError) { "Failed to update building ${bldLike.id} during close for playerId=$playerId: ${it.message}" }
                }
            }
            Result.success(Unit)
        }.getOrElse { e ->
            Logger.error(LogConfigSocketError) { "Failed to close CompoundService for playerId=$playerId: ${e.message}" }
            Result.failure(e)
        }
    }

    private fun isProductionBuilding(idInXML: String): Boolean {
        return idInXML.contains("resource")
    }
}