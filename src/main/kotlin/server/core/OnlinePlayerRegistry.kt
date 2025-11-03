package server.core

import io.ktor.util.date.*
import java.util.concurrent.ConcurrentHashMap

data class PlayerStatus(
    val playerId: String,
    val onlineSince: Long,
)

class OnlinePlayerRegistry {
    private val players = ConcurrentHashMap<String, PlayerStatus>()

    fun markOnline(playerId: String) {
        players[playerId] = PlayerStatus(
            playerId = playerId,
            onlineSince = getTimeMillis(),
        )
    }

    fun markOffline(playerId: String) {
        players.remove(playerId)
    }

    fun shutdown() {
        players.clear()
    }
}
