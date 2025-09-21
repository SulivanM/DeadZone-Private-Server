package user.auth

import user.model.PlayerSession
import core.data.AdminData
import utils.UUID
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
    private val sessions = ConcurrentHashMap<String, PlayerSession>()
    private val CLEANUP_INTERVAL_MS = 5 * 60 * 1000L
    private val cleanupJob = Job()
    private val SESSION_DURATION_MS = 1 * 60 * 60 * 1000L
    private val SESSION_LIFETIME_MS = 6 * 60 * 60 * 1000L
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
        val session = sessions[token] ?: return false
        val now = getTimeMillis()

        if (now >= session.expiresAt) {
            sessions.remove(token)
            return false
        }

        return true
    }

    fun refresh(token: String): Boolean {
        val session = sessions[token] ?: return false
        val now = getTimeMillis()

        val lifetime = now - session.issuedAt
        if (lifetime > SESSION_LIFETIME_MS) {
            sessions.remove(token)
            return false
        }

        session.expiresAt = now + 1 * 60 * 60 * 1000
        return true
    }

    fun getPlayerId(token: String): String? {
        return sessions[token]?.takeIf { getTimeMillis() < it.expiresAt }?.playerId
    }

    fun cleanupExpiredSessions() {
        val now = getTimeMillis()
        val expiredKeys = sessions.filterValues { it.expiresAt <= now }.keys
        expiredKeys.forEach { sessions.remove(it) }
    }

    fun shutdown() {
        sessions.clear()
        cleanupJob.cancel()
    }
}
