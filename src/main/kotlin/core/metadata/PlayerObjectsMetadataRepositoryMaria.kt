package dev.deadzone.core.metadata

import dev.deadzone.data.collection.PlayerObjects
import dev.deadzone.data.db.PlayerObjectsTable
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.SqlExpressionBuilder.eq
import org.jetbrains.exposed.sql.transactions.transaction

class PlayerObjectsMetadataRepositoryMaria(private val database: Database) : PlayerObjectsMetadataRepository {
    private val json = Json { ignoreUnknownKeys = true }
    
    override suspend fun getPlayerFlags(playerId: String): Result<ByteArray> {
        return runCatching {
            transaction(database) {
                PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        val playerObjects = json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                        playerObjects.flags
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
            }
        }
    }
    
    override suspend fun updatePlayerFlags(playerId: String, flags: ByteArray): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
                
                val updatedData = currentData.copy(flags = flags)
                val updateResult = PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }
                
                if (updateResult == 0) {
                    throw NoSuchElementException("No player found with id=$playerId")
                }
            }
        }
    }
    
    override suspend fun getPlayerNickname(playerId: String): Result<String?> {
        return runCatching {
            transaction(database) {
                PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        val playerObjects = json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                        playerObjects.nickname
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
            }
        }
    }
    
    override suspend fun updatePlayerNickname(playerId: String, nickname: String): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = PlayerObjectsTable.select { PlayerObjectsTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(PlayerObjects.serializer(), row[PlayerObjectsTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
                
                val updatedData = currentData.copy(nickname = nickname)
                val updateResult = PlayerObjectsTable.update({ PlayerObjectsTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(PlayerObjects.serializer(), updatedData)
                }
                
                if (updateResult == 0) {
                    throw NoSuchElementException("No player found with id=$playerId")
                }
            }
        }
    }
}