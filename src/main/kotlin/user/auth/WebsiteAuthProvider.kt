package dev.deadzone.user.auth

import dev.deadzone.core.auth.AuthProvider
import dev.deadzone.core.auth.SessionManager
import dev.deadzone.core.auth.model.PlayerSession
import dev.deadzone.core.data.AdminData
import dev.deadzone.data.db.BigDB
import dev.deadzone.user.PlayerAccountRepository
import dev.deadzone.utils.LogConfigAPIError
import dev.deadzone.utils.Logger

class WebsiteAuthProvider(
    private val db: BigDB,
    private val playerAccountRepository: PlayerAccountRepository,
    private val sessionManager: SessionManager
) : AuthProvider {
    override suspend fun register(username: String, password: String): PlayerSession {
        val pid = db.createUser(username, password)
        return sessionManager.create(playerId = pid)
    }

    override suspend fun login(username: String, password: String): PlayerSession? {
        val result = playerAccountRepository.verifyCredentials(username, password)
        result.onFailure {
            Logger.error(LogConfigAPIError) { "Failure on verifyCredentials for username=$username: ${it.message}" }
        }
        val pid = requireNotNull(result.getOrThrow()) {
            "verifyCredentials succeed but returned pid is null"
        }
        return sessionManager.create(pid)
    }

    override suspend fun adminLogin(): PlayerSession? {
        return sessionManager.create(AdminData.PLAYER_ID)
    }

    override suspend fun doesUserExist(username: String): Boolean {
        val result = playerAccountRepository.doesUserExist(username)
        result.onFailure {
            Logger.error(LogConfigAPIError) { "Failure on doesUserExist for username=$username: ${it.message}" }
        }
        val doesExist = requireNotNull(result.getOrThrow()) {
            "doesUserExist succeed but returned boolean is null"
        }
        return doesExist
    }
}