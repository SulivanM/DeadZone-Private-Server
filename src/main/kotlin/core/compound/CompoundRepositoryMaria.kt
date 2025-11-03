package core.compound

import core.model.game.data.BuildingLike
import core.model.game.data.GameResources
import core.model.game.data.id
import data.collection.PlayerObjects
import data.db.PlayerAccounts
import data.db.suspendedTransactionResult
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import utils.JSON

class CompoundRepositoryMaria(private val database: Database) : CompoundRepository {

    private suspend fun <T> getPlayerObjectsData(playerId: String, transform: (PlayerObjects) -> T): Result<T> {
        return database.suspendedTransactionResult {
            PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    val playerObjects =
                        JSON.decode(PlayerObjects.serializer(), row[PlayerAccounts.playerObjectsJson])
                    transform(playerObjects)
                } ?: throw NoSuchElementException("getPlayerObjectsData: No PlayerObjects found with id=$playerId")
        }
    }

    private suspend fun updatePlayerObjectsData(
        playerId: String,
        updateAction: (PlayerObjects) -> PlayerObjects
    ): Result<Unit> {
        return database.suspendedTransactionResult {
            val currentRow = PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                .singleOrNull() ?: throw NoSuchElementException("No player found with id=$playerId")

            val currentData = JSON.decode(PlayerObjects.serializer(), currentRow[PlayerAccounts.playerObjectsJson])
            val updatedData = updateAction(currentData)

            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[playerObjectsJson] = JSON.encode(PlayerObjects.serializer(), updatedData)
            }
            if (rowsUpdated == 0) {
                throw Exception("Failed to update PlayerObjects in updatePlayerObjectsData for playerId=$playerId")
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

    override suspend fun updateAllBuildings(
        playerId: String,
        updatedBuildings: List<BuildingLike>
    ): Result<Unit> {
        return updatePlayerObjectsData(playerId) { currentData ->
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
