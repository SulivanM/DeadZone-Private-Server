package core.survivor

import core.model.game.data.Survivor
import data.collection.PlayerObjects
import data.db.PlayerAccounts
import data.db.suspendedTransactionResult
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import utils.JSON

class SurvivorRepositoryMaria(private val database: Database) : SurvivorRepository {
    override suspend fun getSurvivors(playerId: String): Result<List<Survivor>> {
        return database.suspendedTransactionResult {
            PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    val playerObjects =
                        JSON.decode(PlayerObjects.serializer(), row[PlayerAccounts.playerObjectsJson])
                    playerObjects.survivors
                } ?: throw NoSuchElementException("getSurvivors: No PlayerObjects found with id=$playerId")
        }
    }

    override suspend fun addSurvivor(playerId: String, survivor: Survivor): Result<Unit> {
        return database.suspendedTransactionResult {
            val currentData = PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    JSON.decode(PlayerObjects.serializer(), row[PlayerAccounts.playerObjectsJson])
                } ?: throw NoSuchElementException("addSurvivor: No PlayerObjects found with id=$playerId")

            val survivors = currentData.survivors.toMutableList()
            val updatedData = currentData.copy(survivors = survivors + survivor)

            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[playerObjectsJson] = JSON.encode(PlayerObjects.serializer(), updatedData)
            }
            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to update survivors in addSurvivor for playerId=$playerId")
            }
        }
    }

    override suspend fun updateSurvivor(playerId: String, srvId: String, updatedSurvivor: Survivor): Result<Unit> {
        return database.suspendedTransactionResult {
            val currentData = PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    JSON.decode(PlayerObjects.serializer(), row[PlayerAccounts.playerObjectsJson])
                } ?: throw NoSuchElementException("updateSurvivor: No PlayerObjects found with id=$playerId")

            val survivors = currentData.survivors.toMutableList()
            val survivorIndex = survivors.indexOfFirst { it.id == srvId }
            if (survivorIndex == -1) {
                throw NoSuchElementException("Survivor for playerId=$playerId srvId=$srvId not found")
            }

            survivors[survivorIndex] = updatedSurvivor
            val updatedData = currentData.copy(survivors = survivors)

            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[playerObjectsJson] = JSON.encode(PlayerObjects.serializer(), updatedData)
            }
            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to update survivors in updateSurvivor for playerId=$playerId")
            }
        }
    }

    override suspend fun updateSurvivors(playerId: String, survivors: List<Survivor>): Result<Unit> {
        return database.suspendedTransactionResult {
            val currentData = PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    JSON.decode(PlayerObjects.serializer(), row[PlayerAccounts.playerObjectsJson])
                } ?: throw NoSuchElementException("updateSurvivors: No PlayerObjects with id=$playerId")

            val updatedData = currentData.copy(survivors = survivors)

            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[playerObjectsJson] = JSON.encode(PlayerObjects.serializer(), updatedData)
            }
            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to update survivors in updateSurvivors for playerId=$playerId")
            }
        }
    }
}
