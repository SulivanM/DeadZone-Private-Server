package core.survivor

import core.model.game.data.Survivor
import data.collection.PlayerObjects
import data.db.PlayerObjectsTable
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update

class SurvivorRepositoryMaria(private val database: Database, private val json: Json) : SurvivorRepository {
    override suspend fun getSurvivors(playerId: String): Result<List<Survivor>> {
        return runCatching {
            transaction(database) {
                PlayerObjectsTable.selectAll().where { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        val playerObjects =
                            json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                        playerObjects.survivors
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
            }
        }
    }

    override suspend fun addSurvivor(playerId: String, survivor: Survivor): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = PlayerObjectsTable.selectAll().where { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")

                val survivors = currentData.survivors.toMutableList()

                val updatedData = currentData.copy(survivors = survivors + survivor)
                PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }
            }
        }
    }

    override suspend fun updateSurvivor(playerId: String, srvId: String, updatedSurvivor: Survivor): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = PlayerObjectsTable.selectAll().where { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
                val survivors = currentData.survivors.toMutableList()
                val survivorIndex = survivors.indexOfFirst { it.id == srvId }
                if (survivorIndex == -1) {
                    throw NoSuchElementException("Survivor for playerId=$playerId srvId=$srvId not found")
                }
                survivors[survivorIndex] = updatedSurvivor
                val updatedData = currentData.copy(survivors = survivors)
                PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }
            }
        }
    }

    override suspend fun updateSurvivors(playerId: String, survivors: List<Survivor>): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = PlayerObjectsTable.selectAll().where { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
                val updatedData = currentData.copy(survivors = survivors)
                PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }
            }
        }
    }
}