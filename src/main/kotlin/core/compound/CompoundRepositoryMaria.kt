package dev.deadzone.core.compound

import dev.deadzone.core.model.game.data.BuildingLike
import dev.deadzone.core.model.game.data.GameResources
import dev.deadzone.core.model.game.data.id
import dev.deadzone.data.collection.PlayerObjects
import dev.deadzone.data.db.PlayerObjectsTable
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction

class CompoundRepositoryMaria(private val database: Database) : CompoundRepository {
    private val json = Json { ignoreUnknownKeys = true }

    override suspend fun getGameResources(playerId: String): Result<GameResources> {
        return runCatching {
            transaction(database) {
                PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson]).resources
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
            }
        }
    }

    override suspend fun updateGameResources(playerId: String, newResources: GameResources): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
                val updatedData = currentData.copy(resources = newResources)
                PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }
            }
        }
    }

    override suspend fun createBuilding(playerId: String, newBuilding: BuildingLike): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
                val updatedBuildings = currentData.buildings.toMutableList().apply { add(newBuilding) }
                val updatedData = currentData.copy(buildings = updatedBuildings)
                PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }
            }
        }
    }

    override suspend fun getBuildings(playerId: String): Result<List<BuildingLike>> {
        return runCatching {
            transaction(database) {
                PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson]).buildings
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
            }
        }
    }

    override suspend fun updateBuilding(playerId: String, bldId: String, updatedBuilding: BuildingLike): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
                val updatedBuildings = currentData.buildings.toMutableList()
                val buildingIndex = updatedBuildings.indexOfFirst { it.id == bldId }
                if (buildingIndex == -1) {
                    throw NoSuchElementException("No building found for bldId=$bldId on playerId=$playerId")
                }
                updatedBuildings[buildingIndex] = updatedBuilding
                val updatedData = currentData.copy(buildings = updatedBuildings)
                PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }
            }
        }
    }

    override suspend fun deleteBuilding(playerId: String, bldId: String): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
                val updatedBuildings = currentData.buildings.toMutableList()
                val removed = updatedBuildings.removeIf { it.id == bldId }
                if (!removed) {
                    throw NoSuchElementException("No building found for bldId=$bldId on playerId=$playerId")
                }
                val updatedData = currentData.copy(buildings = updatedBuildings)
                PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }
            }
        }
    }

    suspend fun getPlayerObjects(playerId: String): Result<PlayerObjects> = runCatching {
        transaction(database) {
            PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                .singleOrNull()?.let { row ->
                    json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                } ?: throw NoSuchElementException("No player found with id=$playerId")
        }
    }

    suspend fun updatePlayerObjects(playerId: String, playerObjects: PlayerObjects): Result<Unit> = runCatching {
        transaction(database) {
            PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                it[dataJson] = json.encodeToString(PlayerObjects.serializer(), playerObjects)
            }
        }
    }
}