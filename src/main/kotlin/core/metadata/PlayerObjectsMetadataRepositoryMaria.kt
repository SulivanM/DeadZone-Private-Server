package core.metadata

import data.collection.PlayerObjects
import data.db.PlayerAccounts
import data.db.suspendedTransactionResult
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import common.JSON

class PlayerObjectsMetadataRepositoryMaria(private val database: Database) : PlayerObjectsMetadataRepository {
    companion object {
        const val MAX_CHAT_CONTACTS = 50
        const val MAX_CHAT_BLOCKS = 50
    }
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

    // Chat contacts and blocks implementation
    override suspend fun getChatContacts(playerId: String): Result<List<String>> {
        return getPlayerObjectsData(playerId) { it.chatContacts }
    }

    override suspend fun addChatContact(playerId: String, nickname: String): Result<Boolean> {
        return database.suspendedTransactionResult {
            val currentRow = PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?: throw NoSuchElementException("addChatContact: No PlayerObjects found with id=$playerId")

            val currentData = JSON.decode(PlayerObjects.serializer(), currentRow[PlayerAccounts.playerObjectsJson])

            // Check if already in contacts
            if (currentData.chatContacts.contains(nickname)) {
                return@suspendedTransactionResult true
            }

            // Check limit
            if (currentData.chatContacts.size >= MAX_CHAT_CONTACTS) {
                return@suspendedTransactionResult false
            }

            val updatedContacts = currentData.chatContacts + nickname
            val updatedData = currentData.copy(chatContacts = updatedContacts)

            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[playerObjectsJson] = JSON.encode(PlayerObjects.serializer(), updatedData)
            }

            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to add chat contact for playerId=$playerId")
            }

            true
        }
    }

    override suspend fun removeChatContact(playerId: String, nickname: String): Result<Unit> {
        return updatePlayerObjectsData(playerId) {
            it.copy(chatContacts = it.chatContacts.filter { contact -> contact != nickname })
        }
    }

    override suspend fun removeAllChatContacts(playerId: String): Result<Unit> {
        return updatePlayerObjectsData(playerId) { it.copy(chatContacts = emptyList()) }
    }

    override suspend fun getChatBlocks(playerId: String): Result<List<String>> {
        return getPlayerObjectsData(playerId) { it.chatBlocks }
    }

    override suspend fun addChatBlock(playerId: String, nickname: String): Result<Boolean> {
        return database.suspendedTransactionResult {
            val currentRow = PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?: throw NoSuchElementException("addChatBlock: No PlayerObjects found with id=$playerId")

            val currentData = JSON.decode(PlayerObjects.serializer(), currentRow[PlayerAccounts.playerObjectsJson])

            // Check if already blocked
            if (currentData.chatBlocks.contains(nickname)) {
                return@suspendedTransactionResult true
            }

            // Check limit
            if (currentData.chatBlocks.size >= MAX_CHAT_BLOCKS) {
                return@suspendedTransactionResult false
            }

            val updatedBlocks = currentData.chatBlocks + nickname
            val updatedData = currentData.copy(chatBlocks = updatedBlocks)

            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[playerObjectsJson] = JSON.encode(PlayerObjects.serializer(), updatedData)
            }

            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to add chat block for playerId=$playerId")
            }

            true
        }
    }

    override suspend fun removeChatBlock(playerId: String, nickname: String): Result<Unit> {
        return updatePlayerObjectsData(playerId) {
            it.copy(chatBlocks = it.chatBlocks.filter { block -> block != nickname })
        }
    }

    override suspend fun removeAllChatBlocks(playerId: String): Result<Unit> {
        return updatePlayerObjectsData(playerId) { it.copy(chatBlocks = emptyList()) }
    }
}
