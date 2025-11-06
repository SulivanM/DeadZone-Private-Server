package core.metadata

import data.collection.PlayerObjects
import data.db.PlayerAccounts
import data.db.suspendedTransactionResult
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import utils.JSON

class PlayerObjectsMetadataRepositoryMaria(private val database: Database) : PlayerObjectsMetadataRepository {
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
            val currentRow = PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?: throw NoSuchElementException("updatePlayerObjectsData: No PlayerObjects found with id=$playerId")

            val currentData =
                JSON.decode(PlayerObjects.serializer(), currentRow[PlayerAccounts.playerObjectsJson])
            val updatedData = updateAction(currentData)

            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[playerObjectsJson] = JSON.encode(PlayerObjects.serializer(), updatedData)
            }
            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to update player objects data for playerId=$playerId")
            }
        }
    }

    override suspend fun getPlayerFlags(playerId: String): Result<ByteArray> {
        return getPlayerObjectsData(playerId) { it.flags }
    }

    override suspend fun updatePlayerFlags(playerId: String, flags: ByteArray): Result<Unit> {
        return updatePlayerObjectsData(playerId) { it.copy(flags = flags) }
    }

    override suspend fun getPlayerNickname(playerId: String): Result<String?> {
        return getPlayerObjectsData(playerId) { it.nickname }
    }

    override suspend fun updatePlayerNickname(playerId: String, nickname: String): Result<Unit> {
        return updatePlayerObjectsData(playerId) { it.copy(nickname = nickname) }
    }

    override suspend fun clearNotifications(playerId: String): Result<Unit> {
        return updatePlayerObjectsData(playerId) { it.copy(notifications = emptyList()) }
    }
}
