package server.handler.save.arena

import data.collection.ArenaLeaderboardEntry
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.util.concurrent.ConcurrentHashMap

object ArenaLeaderboardCache {
    private data class CacheEntry(
        val data: List<ArenaLeaderboardEntry>,
        val timestamp: Long
    )

    private val cache = ConcurrentHashMap<String, CacheEntry>()
    private val mutex = Mutex()

    private const val CACHE_TTL_MS = 30_000L

    suspend fun get(arenaName: String): List<ArenaLeaderboardEntry>? = mutex.withLock {
        val entry = cache[arenaName] ?: return null
        val now = System.currentTimeMillis()

        return if (now - entry.timestamp < CACHE_TTL_MS) {
            entry.data
        } else {
            cache.remove(arenaName)
            null
        }
    }

    suspend fun put(arenaName: String, data: List<ArenaLeaderboardEntry>) = mutex.withLock {
        cache[arenaName] = CacheEntry(
            data = data,
            timestamp = System.currentTimeMillis()
        )
    }

    suspend fun invalidate(arenaName: String): Unit = mutex.withLock {
        cache.remove(arenaName)
    }

    suspend fun clear() = mutex.withLock {
        cache.clear()
    }

    suspend fun cleanExpired() = mutex.withLock {
        val now = System.currentTimeMillis()
        cache.entries.removeIf { (_, entry) ->
            now - entry.timestamp >= CACHE_TTL_MS
        }
    }
}
