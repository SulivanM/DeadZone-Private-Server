package user

import user.model.UserProfile
import data.collection.PlayerAccount

interface PlayerAccountRepository {
    suspend fun doesUserExist(username: String): Result<Boolean>

    suspend fun getUserDocByUsername(username: String): Result<PlayerAccount?>

    suspend fun getUserDocByPlayerId(playerId: String): Result<PlayerAccount?>

    suspend fun getPlayerIdOfUsername(username: String): Result<String?>

    suspend fun getProfileOfPlayerId(playerId: String): Result<UserProfile?>

    suspend fun updatePlayerAccount(playerId: String, account: PlayerAccount): Result<Unit>

    suspend fun updateLastLogin(playerId: String, lastLogin: Long): Result<Unit>

    suspend fun verifyCredentials(username: String, password: String): Result<String?>
}
