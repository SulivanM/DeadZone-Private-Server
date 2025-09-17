package dev.deadzone.core.survivor

import dev.deadzone.core.model.game.data.Survivor
import dev.deadzone.data.collection.PlayerObjects
import dev.deadzone.data.db.PlayerObjectsTable
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction

class SurvivorRepositoryMaria(private val database: Database) : SurvivorRepository {
    private val json = Json { ignoreUnknownKeys = true }
    
    override suspend fun getSurvivors(playerId: String): Result<List<Survivor>> {
        return runCatching {
            transaction(database) {
                PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        val playerObjects = json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                        playerObjects.survivors
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
            }
        }
    }
    
    override suspend fun updateSurvivor(playerId: String, srvId: String, updatedSurvivor: Survivor): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
                
                val updatedSurvivors = currentData.survivors.toMutableList()
                val survivorIndex = updatedSurvivors.indexOfFirst { it.id == srvId }
                if (survivorIndex == -1) {
                    throw NoSuchElementException("Survivor for playerId=$playerId srvId=$srvId not found")
                }
                updatedSurvivors[survivorIndex] = updatedSurvivor
                
                val updatedData = currentData.copy(survivors = updatedSurvivors)
                PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }
            }
        }
    }
}