package user

import com.toxicbakery.bcrypt.Bcrypt
import data.collection.PlayerAccount
import data.collection.ServerMetadata
import data.db.PlayerAccounts
import utils.Logger
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update
import user.model.UserProfile
import kotlin.io.encoding.Base64

class PlayerAccountRepositoryMaria(private val database: Database?) : PlayerAccountRepository {
    private val json = Json {
        ignoreUnknownKeys = true
        encodeDefaults = true
    }

    override suspend fun verifyCredentials(username: String, password: String): Result<String?> {
        return try {
            transaction(database) {
                val row = PlayerAccounts.selectAll()
                    .where { PlayerAccounts.displayName eq username }
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
                PlayerAccounts.selectAll()
                    .where { PlayerAccounts.displayName eq username }
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
                PlayerAccounts.selectAll()
                    .where { PlayerAccounts.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        UserProfile(
                            playerId = row[PlayerAccounts.playerId],
                            email = row[PlayerAccounts.email],
                            displayName = row[PlayerAccounts.displayName],
                            avatarUrl = row[PlayerAccounts.avatarUrl],
                            createdAt = row[PlayerAccounts.createdAt],
                            lastLogin = row[PlayerAccounts.lastLogin],
                            countryCode = row[PlayerAccounts.countryCode],
                            friends = emptySet(),
                            enemies = emptySet()
                        )
                    } ?: run {
                    Logger.warn { "No UserProfile found for playerId=$playerId" }
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
                PlayerAccounts.selectAll()
                    .where { PlayerAccounts.displayName eq username }
                    .singleOrNull()?.let { row ->
                        PlayerAccount(
                            playerId = row[PlayerAccounts.playerId],
                            hashedPassword = row[PlayerAccounts.hashedPassword],
                            email = row[PlayerAccounts.email],
                            displayName = row[PlayerAccounts.displayName],
                            avatarUrl = row[PlayerAccounts.avatarUrl],
                            createdAt = row[PlayerAccounts.createdAt],
                            lastLogin = row[PlayerAccounts.lastLogin],
                            countryCode = row[PlayerAccounts.countryCode],
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
                PlayerAccounts.selectAll()
                    .where { PlayerAccounts.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        PlayerAccount(
                            playerId = row[PlayerAccounts.playerId],
                            hashedPassword = row[PlayerAccounts.hashedPassword],
                            email = row[PlayerAccounts.email],
                            displayName = row[PlayerAccounts.displayName],
                            avatarUrl = row[PlayerAccounts.avatarUrl],
                            createdAt = row[PlayerAccounts.createdAt],
                            lastLogin = row[PlayerAccounts.lastLogin],
                            countryCode = row[PlayerAccounts.countryCode],
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
                PlayerAccounts.selectAll()
                    .where { PlayerAccounts.displayName eq username }
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
                    it[email] = account.email
                    it[displayName] = account.displayName
                    it[avatarUrl] = account.avatarUrl
                    it[createdAt] = account.createdAt
                    it[lastLogin] = account.lastLogin
                    it[countryCode] = account.countryCode
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
                val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                    it[PlayerAccounts.lastLogin] = lastLogin
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