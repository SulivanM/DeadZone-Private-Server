package server.core

import io.ktor.util.date.*
import java.util.concurrent.ConcurrentHashMap

data class PlayerStatus(
    val playerId: String,
    val onlineSince: Long,
)

/**
 * Keeps track online players
 */
class OnlinePlayerRegistry {
    private val players = ConcurrentHashMap<String, PlayerStatus>()

    /**
     * Mark a player of [playerId] as online. Does nothing if player is already online
     */
    fun markOnline(playerId: String) {
        players[playerId] = PlayerStatus(
            playerId = playerId,
            onlineSince = getTimeMillis(),
        )
    }

    /**
     * Mark a player of [playerId] as offline. Does nothing if player is already offline
     */
    fun markOffline(playerId: String) {
        players.remove(playerId)
    }

    /**
     * Check if a player is currently online
     */
    fun isOnline(playerId: String): Boolean {
        return players.containsKey(playerId)
    }

    /**
     * Clear all players
     */
    fun shutdown() {
        players.clear()
    }
}
