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

    suspend fun cancelBuilding(bldId: String): Result<Unit> {
        val result = compoundRepository.deleteBuilding(playerId, bldId)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on cancelBuilding for playerId=$playerId: ${it.message}" }
        }
        result.onSuccess {
            buildings.removeIf { it.id == bldId }
        }
        return result
    }

    suspend fun collectBuilding(bldId: String): Result<GameResources> {
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
        return Result.success(res)
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
        }
    }

    private fun isProductionBuilding(idInXML: String): Boolean {
        return idInXML.contains("resource")
    }
}