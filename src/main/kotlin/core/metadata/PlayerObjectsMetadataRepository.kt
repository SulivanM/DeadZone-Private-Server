package dev.deadzone.core.metadata

/**
 * Repository for uncategorized fields in PlayerObjects like nickname, flags
 */
interface PlayerObjectsMetadataRepository {
    suspend fun getPlayerFlags(playerId: String): Result<ByteArray>
    suspend fun updatePlayerFlags(playerId: String, flags: ByteArray): Result<Unit>

    suspend fun getPlayerNickname(playerId: String): Result<String?>
    suspend fun updatePlayerNickname(playerId: String, nickname: String): Result<Unit>
}
