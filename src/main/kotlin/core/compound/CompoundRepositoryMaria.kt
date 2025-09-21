package core.compound

import core.model.game.data.BuildingLike
import core.model.game.data.GameResources
import core.model.game.data.id
import data.collection.PlayerObjects
import data.db.PlayerObjectsTable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.select
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq

class CompoundRepositoryMaria(
    private val database: Database,
    private val json: Json
) : CompoundRepository {

    private suspend fun <T> getPlayerObjectsData(playerId: String, transform: (PlayerObjects) -> T): Result<T> {
        return runCatching {
            transaction(database) {
                PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        val playerObjects = json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                        transform(playerObjects)
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
            }
        }
    }

    private suspend fun updatePlayerObjectsData(playerId: String, updateAction: (PlayerObjects) -> PlayerObjects): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentRow = PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull() ?: throw NoSuchElementException("No player found with id=$playerId")

                val currentData = json.decodeFromString(PlayerObjects.serializer(), currentRow[PlayerObjectsTable.dataJson])
                val updatedData = updateAction(currentData)

                val updateResult = PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }

                if (updateResult == 0) {
                    throw Exception("Failed to update player objects for playerId=$playerId")
                }
            }
        }
    }

    override suspend fun getGameResources(playerId: String): Result<GameResources> {
        return getPlayerObjectsData(playerId) { it.resources }
    }

    override suspend fun updateGameResources(playerId: String, newResources: GameResources): Result<Unit> {
        return updatePlayerObjectsData(playerId) { it.copy(resources = newResources) }
    }

    override suspend fun createBuilding(playerId: String, newBuilding: BuildingLike): Result<Unit> {
        return updatePlayerObjectsData(playerId) { currentData ->
            currentData.copy(buildings = currentData.buildings + newBuilding)
        }
    }

    override suspend fun getBuildings(playerId: String): Result<List<BuildingLike>> {
        return getPlayerObjectsData(playerId) { it.buildings }
    }

    override suspend fun updateBuilding(playerId: String, bldId: String, updatedBuilding: BuildingLike): Result<Unit> {
        return updatePlayerObjectsData(playerId) { currentData ->
            val updatedBuildings = currentData.buildings.toMutableList()
            val buildingIndex = updatedBuildings.indexOfFirst { it.id == bldId }
            if (buildingIndex == -1) {
                throw NoSuchElementException("No building found for bldId=$bldId on playerId=$playerId")
            }
            updatedBuildings[buildingIndex] = updatedBuilding
            currentData.copy(buildings = updatedBuildings)
        }
    }

    override suspend fun deleteBuilding(playerId: String, bldId: String): Result<Unit> {
        return updatePlayerObjectsData(playerId) { currentData ->
            val updatedBuildings = currentData.buildings.filterNot { it.id == bldId }
            currentData.copy(buildings = updatedBuildings)
        }
    }
}