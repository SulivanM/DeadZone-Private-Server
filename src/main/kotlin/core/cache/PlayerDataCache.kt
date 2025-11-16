package core.cache

import data.collection.Inventory
import data.collection.NeighborHistory
import data.collection.PlayerObjects
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.util.concurrent.ConcurrentHashMap
import kotlin.time.Duration
import kotlin.time.Duration.Companion.minutes

/**
 * In-memory cache for player data to reduce database queries
 */
class PlayerDataCache(
    private val ttl: Duration = 15.minutes
) {
    private data class CachedEntry<T>(
        val data: T,
        val timestamp: Long = System.currentTimeMillis()
    ) {
        fun isExpired(ttl: Duration): Boolean {
            return System.currentTimeMillis() - timestamp > ttl.inWholeMilliseconds
        }
    }

    private val playerObjectsCache = ConcurrentHashMap<String, CachedEntry<PlayerObjects>>()
    private val inventoryCache = ConcurrentHashMap<String, CachedEntry<Inventory>>()
    private val neighborHistoryCache = ConcurrentHashMap<String, CachedEntry<NeighborHistory>>()

    private val cleanupMutex = Mutex()
    private var lastCleanup = System.currentTimeMillis()

    /**
     * Get PlayerObjects from cache
     */
    fun getPlayerObjects(playerId: String): PlayerObjects? {
        val entry = playerObjectsCache[playerId] ?: return null
        if (entry.isExpired(ttl)) {
            playerObjectsCache.remove(playerId)
            return null
        }
        return entry.data
    }

    /**
     * Put PlayerObjects into cache
     */
    fun putPlayerObjects(playerId: String, data: PlayerObjects) {
        playerObjectsCache[playerId] = CachedEntry(data)
        scheduleCleanup()
    }

    /**
     * Get Inventory from cache
     */
    fun getInventory(playerId: String): Inventory? {
        val entry = inventoryCache[playerId] ?: return null
        if (entry.isExpired(ttl)) {
            inventoryCache.remove(playerId)
            return null
        }
        return entry.data
    }

    /**
     * Put Inventory into cache
     */
    fun putInventory(playerId: String, data: Inventory) {
        inventoryCache[playerId] = CachedEntry(data)
        scheduleCleanup()
    }

    /**
     * Get NeighborHistory from cache
     */
    fun getNeighborHistory(playerId: String): NeighborHistory? {
        val entry = neighborHistoryCache[playerId] ?: return null
        if (entry.isExpired(ttl)) {
            neighborHistoryCache.remove(playerId)
            return null
        }
        return entry.data
    }

    /**
     * Put NeighborHistory into cache
     */
    fun putNeighborHistory(playerId: String, data: NeighborHistory) {
        neighborHistoryCache[playerId] = CachedEntry(data)
        scheduleCleanup()
    }

    /**
     * Invalidate all cache entries for a player
     */
    fun invalidate(playerId: String) {
        playerObjectsCache.remove(playerId)
        inventoryCache.remove(playerId)
        neighborHistoryCache.remove(playerId)
    }

    /**
     * Clear all cache
     */
    fun clear() {
        playerObjectsCache.clear()
        inventoryCache.clear()
        neighborHistoryCache.clear()
    }

    /**
     * Get cache statistics
     */
    fun getStats(): CacheStats {
        return CacheStats(
            playerObjectsSize = playerObjectsCache.size,
            inventorySize = inventoryCache.size,
            neighborHistorySize = neighborHistoryCache.size,
            totalSize = playerObjectsCache.size + inventoryCache.size + neighborHistoryCache.size
        )
    }

    /**
     * Schedule cleanup of expired entries
     */
    private fun scheduleCleanup() {
        if (System.currentTimeMillis() - lastCleanup > 60_000) { // Cleanup every minute
            // Spawn cleanup in background
            CoroutineScope(Dispatchers.Default).launch {
                cleanupMutex.withLock {
                    if (System.currentTimeMillis() - lastCleanup > 60_000) {
                        cleanup()
                        lastCleanup = System.currentTimeMillis()
                    }
                }
            }
        }
    }

    /**
     * Remove expired entries from all caches
     */
    private fun cleanup() {
        playerObjectsCache.entries.removeIf { it.value.isExpired(ttl) }
        inventoryCache.entries.removeIf { it.value.isExpired(ttl) }
        neighborHistoryCache.entries.removeIf { it.value.isExpired(ttl) }
    }

    data class CacheStats(
        val playerObjectsSize: Int,
        val inventorySize: Int,
        val neighborHistorySize: Int,
        val totalSize: Int
    )
}
