package server.alliance

import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.TimeUnit

class AllianceCreationTracker {
    private data class AllianceCreation(
        val allianceId: String,
        val timestamp: Long = System.currentTimeMillis()
    )

    private val recentCreations = ConcurrentHashMap<String, AllianceCreation>()
    private val expirationMs = TimeUnit.MINUTES.toMillis(5)

    fun trackCreation(playerId: String, allianceId: String) {
        recentCreations[playerId] = AllianceCreation(allianceId)
        cleanupExpired()
    }

    fun getRecentlyCreated(playerId: String): String? {
        val creation = recentCreations[playerId] ?: return null

        if (System.currentTimeMillis() - creation.timestamp > expirationMs) {
            recentCreations.remove(playerId)
            return null
        }

        return creation.allianceId
    }

    fun clearTracking(playerId: String) {
        recentCreations.remove(playerId)
    }

    private fun cleanupExpired() {
        val now = System.currentTimeMillis()
        recentCreations.entries.removeIf { (_, creation) ->
            now - creation.timestamp > expirationMs
        }
    }
}
