package dev.deadzone.user

import com.toxicbakery.bcrypt.Bcrypt
import dev.deadzone.data.collection.PlayerAccount
import dev.deadzone.data.db.PlayerAccounts
import dev.deadzone.user.model.UserProfile
import dev.deadzone.utils.Logger
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import kotlin.io.encoding.Base64


class PlayerAccountRepositoryMaria(private val database: Database?) : PlayerAccountRepository {
    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }

    override suspend fun verifyCredentials(username: String, password: String): Result<String?> {
        return try {
            transaction(database) {
                val row =
                    PlayerAccounts.selectAll().where { PlayerAccounts.profileJson like "%\"username\":\"$username\"%" }
                    .singleOrNull()
                if (row == null) {
                    Logger.info { "No account found for username=$username" }
                    return@transaction null
                }
                val hashedPassword = row[PlayerAccounts.hashedPassword]
                val decodedHash = Base64.decode(hashedPassword)
                if (Bcrypt.verify(password, decodedHash)) {
                    row[PlayerAccounts.playerId]
                } else {
                    Logger.info { "Password verification failed for username=$username" }
                    null
                }
            }.let { Result.success(it) }
        } catch (e: Exception) {
            Logger.error { "Failed to verify credentials for username=$username: ${e.message}" }
            Result.failure(e)
        }
    }

    override suspend fun doesUserExist(username: String): Result<Boolean> {
        return try {
            transaction(database) {
                PlayerAccounts.selectAll().where { PlayerAccounts.profileJson like "%\"username\":\"$username\"%" }
                    .count() > 0
            }.let { Result.success(it) }
        } catch (e: Exception) {
            Logger.error { "Failed to check if user exists for username=$username: ${e.message}" }
            Result.failure(e)
        }
    }

    override suspend fun getProfileOfPlayerId(playerId: String): Result<UserProfile?> {
        return try {
            transaction(database) {
                PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        val profileJson = row[PlayerAccounts.profileJson]
                        if (profileJson.isNotEmpty()) {
                            json.decodeFromString<UserProfile>(profileJson)
                        } else {
                            Logger.warn { "Profile JSON is empty for playerId=$playerId" }
                            null
                        }
                    } ?: run {
                    Logger.info { "No profile found for playerId=$playerId" }
                    null
                }
            }.let { profile ->
                if (profile == null) {
                    Logger.warn { "getProfileOfPlayerId returned null for playerId=$playerId" }
                    Result.failure(Exception("Profile not found for playerId=$playerId"))
                } else {
                    Result.success(profile)
                }
            }
        } catch (e: Exception) {
            Logger.error { "Failed to get profile for playerId=$playerId: ${e.message}" }
            Result.failure(e)
        }
    }

    override suspend fun getUserDocByUsername(username: String): Result<PlayerAccount?> {
        return try {
            transaction(database) {
                PlayerAccounts.selectAll().where { PlayerAccounts.profileJson like "%\"username\":\"$username\"%" }
                    .singleOrNull()?.let { row ->
                        PlayerAccount(
                            playerId = row[PlayerAccounts.playerId],
                            hashedPassword = row[PlayerAccounts.hashedPassword],
                            profile = json.decodeFromString(row[PlayerAccounts.profileJson]),
                            serverMetadata = json.decodeFromString(row[PlayerAccounts.serverMetadataJson])
                        )
                    }
            }.let { Result.success(it) }
        } catch (e: Exception) {
            Logger.error { "Failed to get user doc for username=$username: ${e.message}" }
            Result.failure(e)
        }
    }

    override suspend fun getUserDocByPlayerId(playerId: String): Result<PlayerAccount?> {
        return try {
            transaction(database) {
                PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        PlayerAccount(
                            playerId = row[PlayerAccounts.playerId],
                            hashedPassword = row[PlayerAccounts.hashedPassword],
                            profile = json.decodeFromString(row[PlayerAccounts.profileJson]),
                            serverMetadata = json.decodeFromString(row[PlayerAccounts.serverMetadataJson])
                        )
                    }
            }.let { Result.success(it) }
        } catch (e: Exception) {
            Logger.error { "Failed to get user doc for playerId=$playerId: ${e.message}" }
            Result.failure(e)
        }
    }

    override suspend fun getPlayerIdOfUsername(username: String): Result<String?> {
        return try {
            transaction(database) {
                PlayerAccounts.selectAll().where { PlayerAccounts.profileJson like "%\"username\":\"$username\"%" }
                    .singleOrNull()?.let { row ->
                        row[PlayerAccounts.playerId]
                    }
            }.let { Result.success(it) }
        } catch (e: Exception) {
            Logger.error { "Failed to get playerId for username=$username: ${e.message}" }
            Result.failure(e)
        }
    }

    override suspend fun updatePlayerAccount(playerId: String, account: PlayerAccount): Result<Unit> {
        return try {
            transaction(database) {
                val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                    it[hashedPassword] = account.hashedPassword
                    it[profileJson] = json.encodeToString(account.profile)
                    it[serverMetadataJson] = json.encodeToString(account.serverMetadata)
                }
                if (rowsUpdated == 0) {
                    Logger.warn { "No account found to update for playerId=$playerId" }
                    Result.failure(Exception("No account found for playerId=$playerId"))
                } else {
                    Result.success(Unit)
                }
            }
        } catch (e: Exception) {
            Logger.error { "Failed to update account for playerId=$playerId: ${e.message}" }
            Result.failure(e)
        }
    }

    override suspend fun updateLastLogin(playerId: String, lastLogin: Long): Result<Unit> {
        return try {
            transaction(database) {
                val row = PlayerAccounts.selectAll().where { PlayerAccounts.playerId eq playerId }
                    .singleOrNull()
                if (row == null) {
                    Logger.warn { "No account found to update last login for playerId=$playerId" }
                    return@transaction Result.failure(Exception("No account found for playerId=$playerId"))
                }
                val profile = json.decodeFromString<UserProfile>(row[PlayerAccounts.profileJson])
                val updatedProfile = profile.copy(lastLogin = lastLogin)
                val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                    it[profileJson] = json.encodeToString(updatedProfile)
                }
                if (rowsUpdated == 0) {
                    Logger.warn { "Failed to update last login for playerId=$playerId" }
                    Result.failure(Exception("Failed to update last login for playerId=$playerId"))
                } else {
                    Result.success(Unit)
                }
            }
        } catch (e: Exception) {
            Logger.error { "Failed to update last login for playerId=$playerId: ${e.message}" }
            Result.failure(e)
        }
    }
}