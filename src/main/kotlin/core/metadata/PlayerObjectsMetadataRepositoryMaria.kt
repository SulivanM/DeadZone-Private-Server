package core.metadata

import data.collection.PlayerObjects
import data.db.PlayerObjectsTable
import data.db.suspendedTransactionResult
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update

class PlayerObjectsMetadataRepositoryMaria(
    private val database: Database,
    private val json: Json
) : PlayerObjectsMetadataRepository {

    private suspend fun <T> getPlayerObjectsData(playerId: String, transform: (PlayerObjects) -> T): Result<T> {
        return database.suspendedTransactionResult {
            PlayerObjectsTable
                .selectAll()
                .where { PlayerObjectsTable.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    val playerObjects =
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    transform(playerObjects)
                } ?: throw NoSuchElementException("getPlayerObjectsData: No PlayerObjects found with id=$playerId")
        }
    }

    private suspend fun updatePlayerObjectsData(
        playerId: String,
        updateAction: (PlayerObjects) -> PlayerObjects
    ): Result<Unit> {
        return database.suspendedTransactionResult {
            val currentRow = PlayerObjectsTable
                .selectAll()
                .where { PlayerObjectsTable.playerId eq playerId }
                .singleOrNull()
                ?: throw NoSuchElementException("updatePlayerObjectsData: No PlayerObjects found with id=$playerId")

            val currentData =
                json.decodeFromString(PlayerObjects.serializer(), currentRow[PlayerObjectsTable.dataJson])
            val updatedData = updateAction(currentData)

            val rowsUpdated = PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
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
}
