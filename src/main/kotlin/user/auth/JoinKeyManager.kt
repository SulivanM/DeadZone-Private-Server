package user.auth

import utils.UUID
import io.ktor.util.date.getTimeMillis
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.util.concurrent.ConcurrentHashMap

class JoinKeyManager {
    private data class JoinKeyEntry(
        val userId: String,
        val createdAt: Long,
        val expiresAt: Long
    )
    
    private val joinKeys = ConcurrentHashMap<String, JoinKeyEntry>()
    private val CLEANUP_INTERVAL_MS = 5 * 60 * 1000L
    private val JOIN_KEY_DURATION_MS = 10 * 60 * 1000L 
    private val cleanupJob = Job()
    private val scope = CoroutineScope(Dispatchers.IO + cleanupJob)

    init {
        scope.launch {
            while (isActive) {
                cleanupExpiredKeys()
                delay(CLEANUP_INTERVAL_MS)
            }
        }
    }

    fun create(userId: String): String {
        val now = getTimeMillis()
        val joinKey = UUID.new()
        
        val entry = JoinKeyEntry(
            userId = userId,
            createdAt = now,
            expiresAt = now + JOIN_KEY_DURATION_MS
        )
        
        joinKeys[joinKey] = entry
        return joinKey
    }

    fun resolve(joinKey: String): String? {
        val entry = joinKeys.remove(joinKey) ?: return null
        val now = getTimeMillis()
        
        return if (now < entry.expiresAt) {
            entry.userId
        } else {
            null
        }
    }

    private fun cleanupExpiredKeys() {
        val now = getTimeMillis()
        val expiredKeys = joinKeys.filterValues { it.expiresAt <= now }.keys
        expiredKeys.forEach { joinKeys.remove(it) }
    }

    fun shutdown() {
        joinKeys.clear()
        cleanupJob.cancel()
    }
}
