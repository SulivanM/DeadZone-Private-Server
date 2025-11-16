package user

import com.toxicbakery.bcrypt.Bcrypt
import data.collection.PlayerAccount
import data.db.PlayerAccounts
import data.db.suspendedTransactionResult
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import user.model.UserProfile
import common.JSON
import common.Logger
import kotlin.io.encoding.Base64

class PlayerAccountRepositoryMaria(private val database: Database, private val json: Json) : PlayerAccountRepository {
    @OptIn(kotlin.io.encoding.ExperimentalEncodingApi::class)
    override suspend fun verifyCredentials(username: String, password: String): Result<String?> {
        return database.suspendedTransactionResult {
            val row = PlayerAccounts.selectAll()
                .where { PlayerAccounts.displayName eq username }
                .singleOrNull()
            if (row == null) {
                Logger.info { "No account found for username=$username" }
                return@suspendedTransactionResult null
            }
            val hashedPassword = row[PlayerAccounts.hashedPassword]
            val decodedHash = Base64.decode(hashedPassword)
            if (Bcrypt.verify(password, decodedHash)) {
                row[PlayerAccounts.playerId]
            } else {
                Logger.info { "Password verification failed for username=$username" }
                null
            }
        }
    }

    override suspend fun doesUserExist(username: String): Result<Boolean> {
        return database.suspendedTransactionResult {
            PlayerAccounts.selectAll()
                .where { PlayerAccounts.displayName eq username }
                .count() > 0
        }
    }

    override suspend fun getProfileOfPlayerId(playerId: String): Result<UserProfile?> {
        return database.suspendedTransactionResult {
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
                }
        }
    }

    override suspend fun getUserDocByUsername(username: String): Result<PlayerAccount?> {
        return database.suspendedTransactionResult {
            PlayerAccounts.selectAll()
                .where { PlayerAccounts.displayName eq username }
                .singleOrNull()?.let { mapToPlayerAccount(it) }
        }
    }

    override suspend fun getUserDocByPlayerId(playerId: String): Result<PlayerAccount?> {
        return database.suspendedTransactionResult {
            PlayerAccounts.selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()?.let { mapToPlayerAccount(it) }
        }
    }

    private fun mapToPlayerAccount(row: org.jetbrains.exposed.sql.ResultRow) = PlayerAccount(
        playerId = row[PlayerAccounts.playerId],
        hashedPassword = row[PlayerAccounts.hashedPassword],
        email = row[PlayerAccounts.email],
        displayName = row[PlayerAccounts.displayName],
        avatarUrl = row[PlayerAccounts.avatarUrl],
        createdAt = row[PlayerAccounts.createdAt],
        lastLogin = row[PlayerAccounts.lastLogin],
        countryCode = row[PlayerAccounts.countryCode],
        serverMetadata = JSON.decode(row[PlayerAccounts.serverMetadataJson])
    )

    override suspend fun getPlayerIdOfUsername(username: String): Result<String?> {
        return database.suspendedTransactionResult {
            PlayerAccounts.selectAll()
                .where { PlayerAccounts.displayName eq username }
                .singleOrNull()?.let { row ->
                    row[PlayerAccounts.playerId]
                }
        }
    }

    override suspend fun updatePlayerAccount(playerId: String, account: PlayerAccount): Result<Unit> {
        return database.suspendedTransactionResult {
            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[hashedPassword] = account.hashedPassword
                it[email] = account.email
                it[displayName] = account.displayName
                it[avatarUrl] = account.avatarUrl
                it[createdAt] = account.createdAt
                it[lastLogin] = account.lastLogin
                it[countryCode] = account.countryCode
                it[serverMetadataJson] = JSON.encode(account.serverMetadata)
            }
            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to update player account for playerId=$playerId")
            }
        }
    }

    override suspend fun updateLastLogin(playerId: String, lastLogin: Long): Result<Unit> {
        return database.suspendedTransactionResult {
            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[PlayerAccounts.lastLogin] = lastLogin
            }
            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to update last login for playerId=$playerId")
            }
        }
    }
}
