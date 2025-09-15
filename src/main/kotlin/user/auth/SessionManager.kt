package dev.deadzone.core.auth

import dev.deadzone.core.auth.model.PlayerSession
import dev.deadzone.core.data.AdminData
import dev.deadzone.utils.UUID
import io.ktor.util.date.getTimeMillis
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.util.concurrent.ConcurrentHashMap

/**
 * Manages authentication sessions between web login and game client.
 *
 * - After a successful website login, this class issues a session token for the player.
 * - The client uses this token for API requests.
 * - On API requests, this class verifies if the token is valid and unexpired.
 * - Token will be refreshed upon successful verification.
 * - The client website makes API requests every 50 minutes to refresh the token.
 * This ensures that the token remains valid, even when the game is not actively making API requests.
 * - Session refreshes is limited to 6 hours. This means player will not be able to make API requests after 6 hours online.
 */
class SessionManager {
    private val sessions = ConcurrentHashMap<String, PlayerSession>() // token -> session
    private val CLEANUP_INTERVAL_MS = 5 * 60 * 1000L // 5 minutes
    private val cleanupJob = Job()
    private val SESSION_DURATION_MS = 1 * 60 * 60 * 1000L // 2 hours
    private val SESSION_LIFETIME_MS = 6 * 60 * 60 * 1000L // 6 hours
    private val scope = CoroutineScope(Dispatchers.IO + cleanupJob)

    init {
        scope.launch {
            while (isActive) {
                cleanupExpiredSessions()
                delay(CLEANUP_INTERVAL_MS)
            }
        }
    }

    fun create(playerId: String): PlayerSession {
        val now = getTimeMillis()

        val token = if (playerId == AdminData.PLAYER_ID) {
            AdminData.TOKEN
        } else {
            UUID.new()
        }

        val session = PlayerSession(
            playerId = playerId,
            token = token,
            issuedAt = now,
            expiresAt = now + SESSION_DURATION_MS,
            lifetime = SESSION_LIFETIME_MS
        )

        sessions[token] = session
        return session
    }

    fun verify(token: String): Boolean {
        // token invalid
        val session = sessions[token] ?: return false
        val now = getTimeMillis()

        // token expired
        if (now >= session.expiresAt) {
            sessions.remove(token)
            return false
        }

        return true
    }

    // refreshed every 50 minutes by client
    fun refresh(token: String): Boolean {
        val session = sessions[token] ?: return false
        val now = getTimeMillis()

        // max lifetime exceeded
        val lifetime = now - session.issuedAt
        if (lifetime > SESSION_LIFETIME_MS) {
            sessions.remove(token)
            return false
        }

        session.expiresAt = now + 1 * 60 * 60 * 1000 // refresh to 1 hour
        return true
    }

    fun getPlayerId(token: String): String? {
        return sessions[token]?.takeIf { getTimeMillis() < it.expiresAt }?.playerId
    }

    fun getSession(token: String): PlayerSession? {
        val session = sessions[token] ?: return null
        val now = getTimeMillis()

        return if (now >= session.expiresAt) {
            sessions.remove(token)
            null
        } else {
            session
        }
    }

    fun invalidate(playerId: String) {
        sessions.remove(playerId)
    }

    fun cleanupExpiredSessions() {
        val now = getTimeMillis()
        val expiredKeys = sessions.filterValues { it.expiresAt <= now }.keys
        expiredKeys.forEach { sessions.remove(it) }
    }

    /**
     * Shutdown [cleanupExpiredSessions] task and clear sessions.
     */
    fun shutdown() {
        sessions.clear()
        cleanupJob.cancel()
    }
}
