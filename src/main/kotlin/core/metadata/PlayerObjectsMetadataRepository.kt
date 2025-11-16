package core.metadata

/**
 * Repository for uncategorized fields in PlayerObjects like nickname, flags
 */
interface PlayerObjectsMetadataRepository {
    suspend fun getPlayerFlags(playerId: String): Result<ByteArray>
    suspend fun updatePlayerFlags(playerId: String, flags: ByteArray): Result<Unit>

    suspend fun getPlayerNickname(playerId: String): Result<String?>
    suspend fun updatePlayerNickname(playerId: String, nickname: String): Result<Unit>

    suspend fun clearNotifications(playerId: String): Result<Unit>

    // Chat contacts and blocks
    suspend fun getChatContacts(playerId: String): Result<List<String>>
    suspend fun addChatContact(playerId: String, nickname: String): Result<Boolean>
    suspend fun removeChatContact(playerId: String, nickname: String): Result<Unit>
    suspend fun removeAllChatContacts(playerId: String): Result<Unit>

    suspend fun getChatBlocks(playerId: String): Result<List<String>>
    suspend fun addChatBlock(playerId: String, nickname: String): Result<Boolean>
    suspend fun removeChatBlock(playerId: String, nickname: String): Result<Unit>
    suspend fun removeAllChatBlocks(playerId: String): Result<Unit>
}
