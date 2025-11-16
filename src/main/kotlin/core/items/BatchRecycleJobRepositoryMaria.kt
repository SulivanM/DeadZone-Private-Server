package core.items

import core.model.game.data.BatchRecycleJob
import data.collection.PlayerObjects
import data.db.PlayerAccounts
import data.db.suspendedTransactionResult
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import common.JSON

class BatchRecycleJobRepositoryMaria(private val database: Database) : BatchRecycleJobRepository {
    private suspend fun <T> getPlayerObjectsData(playerId: String, transform: (PlayerObjects) -> T): Result<T> {
        return database.suspendedTransactionResult {
            PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    val playerObjects = JSON.decode(PlayerObjects.serializer(), row[PlayerAccounts.playerObjectsJson])
                    transform(playerObjects)
                } ?: throw NoSuchElementException("getPlayerObjectsData: No PlayerObjects found with id=$playerId")
        }
    }

    private suspend fun updatePlayerObjectsData(
        playerId: String,
        updateAction: (PlayerObjects) -> PlayerObjects
    ): Result<Unit> {
        return database.suspendedTransactionResult {
            val currentRow = PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?: throw NoSuchElementException("updatePlayerObjectsData: No PlayerObjects found with id=$playerId")

            val currentData = JSON.decode(PlayerObjects.serializer(), currentRow[PlayerAccounts.playerObjectsJson])
            val updatedData = updateAction(currentData)

            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[playerObjectsJson] = JSON.encode(PlayerObjects.serializer(), updatedData)
            }
            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to update player objects data for playerId=$playerId")
            }
        }
    }

    override suspend fun getBatchRecycleJobs(playerId: String): Result<List<BatchRecycleJob>> {
        return getPlayerObjectsData(playerId) { it.batchRecycles ?: emptyList() }
    }

    override suspend fun addBatchRecycleJob(playerId: String, job: BatchRecycleJob): Result<Unit> {
        return updatePlayerObjectsData(playerId) { playerObjects ->
            val currentJobs = playerObjects.batchRecycles ?: emptyList()
            playerObjects.copy(batchRecycles = currentJobs + job)
        }
    }

    override suspend fun updateBatchRecycleJob(playerId: String, jobId: String, job: BatchRecycleJob): Result<Unit> {
        return updatePlayerObjectsData(playerId) { playerObjects ->
            val currentJobs = playerObjects.batchRecycles ?: emptyList()
            val updatedJobs = currentJobs.map { if (it.id.equals(jobId, ignoreCase = true)) job else it }
            playerObjects.copy(batchRecycles = updatedJobs)
        }
    }

    override suspend fun removeBatchRecycleJob(playerId: String, jobId: String): Result<Unit> {
        return updatePlayerObjectsData(playerId) { playerObjects ->
            val currentJobs = playerObjects.batchRecycles ?: emptyList()
            val updatedJobs = currentJobs.filter { !it.id.equals(jobId, ignoreCase = true) }
            playerObjects.copy(batchRecycles = updatedJobs)
        }
    }
}
