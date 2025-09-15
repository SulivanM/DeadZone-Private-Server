package dev.deadzone.socket.core

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

    fun isOnline(playerId: String): Boolean {
        return players.contains(playerId)
    }

    fun getStatus(playerId: String): PlayerStatus? {
        return players[playerId]
    }

    fun listOnline(): List<PlayerStatus> {
        return players.values.toList()
    }

    /**
     * Clear all players
     */
    fun shutdown() {
        players.clear()
    }
}
