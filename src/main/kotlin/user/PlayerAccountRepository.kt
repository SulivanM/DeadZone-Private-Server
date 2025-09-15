package dev.deadzone.user

import dev.deadzone.core.auth.model.UserProfile
import dev.deadzone.data.collection.PlayerAccount

/**
 * Player account repository, analogous to game service's repo
 */
interface PlayerAccountRepository {
    suspend fun doesUserExist(username: String): Result<Boolean>

    suspend fun getUserDocByUsername(username: String): Result<PlayerAccount?>

    suspend fun getUserDocByPlayerId(playerId: String): Result<PlayerAccount?>

    suspend fun getPlayerIdOfUsername(username: String): Result<String?>

    suspend fun getProfileOfPlayerId(playerId: String): Result<UserProfile?>

    suspend fun updatePlayerAccount(playerId: String, account: PlayerAccount): Result<Unit>

    suspend fun updateLastLogin(playerId: String, lastLogin: Long): Result<Unit>

    /**
     * Verify credentials of the given username and password
     *
     * @return playerId for the corresponding username if success
     */
    suspend fun verifyCredentials(username: String, password: String): Result<String?>
}
