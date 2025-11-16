package room

import room.chat.ChatChannel
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

/**
 * Gestionnaire des joinKeys pour les connexions aux rooms
 * Les joinKeys sont créés par CreateJoinRoom et utilisés lors du join via socket
 */
object JoinKeyManager {
    // Stockage des informations de join en attente (joinKey -> JoinInfo)
    private val pendingJoins = ConcurrentHashMap<String, JoinInfo>()

    // Service de nettoyage des joinKeys expirés
    private val cleanupExecutor = Executors.newSingleThreadScheduledExecutor()

    // Durée de validité d'un joinKey (5 minutes)
    private val joinKeyValidityDuration = TimeUnit.MINUTES.toMillis(5)

    init {
        // Nettoyer les joinKeys expirés toutes les minutes
        cleanupExecutor.scheduleAtFixedRate({
            cleanupExpiredKeys()
        }, 1, 1, TimeUnit.MINUTES)
    }

    /**
     * Crée un nouveau joinKey et stocke les informations de join
     */
    fun createJoinKey(
        roomId: String,
        roomType: RoomType,
        visible: Boolean,
        roomData: Map<String, Any>,
        joinData: Map<String, Any>,
        isDevRoom: Boolean,
        channel: ChatChannel? = null
    ): String {
        val joinKey = UUID.randomUUID().toString()
        val joinInfo = JoinInfo(
            joinKey = joinKey,
            roomId = roomId,
            roomType = roomType,
            visible = visible,
            roomData = roomData,
            joinData = joinData,
            isDevRoom = isDevRoom,
            channel = channel,
            createdAt = System.currentTimeMillis()
        )

        pendingJoins[joinKey] = joinInfo
        return joinKey
    }

    /**
     * Récupère et supprime les informations de join pour un joinKey
     * @return JoinInfo si le joinKey est valide, null sinon
     */
    fun consumeJoinKey(joinKey: String): JoinInfo? {
        val joinInfo = pendingJoins.remove(joinKey) ?: return null

        // Vérifier si le joinKey est expiré
        if (System.currentTimeMillis() - joinInfo.createdAt > joinKeyValidityDuration) {
            return null
        }

        return joinInfo
    }

    /**
     * Vérifie si un joinKey est valide sans le consommer
     */
    fun isValidJoinKey(joinKey: String): Boolean {
        val joinInfo = pendingJoins[joinKey] ?: return false
        return System.currentTimeMillis() - joinInfo.createdAt <= joinKeyValidityDuration
    }

    /**
     * Nettoie les joinKeys expirés
     */
    private fun cleanupExpiredKeys() {
        val now = System.currentTimeMillis()
        val expiredKeys = pendingJoins.entries
            .filter { (_, joinInfo) ->
                now - joinInfo.createdAt > joinKeyValidityDuration
            }
            .map { it.key }

        expiredKeys.forEach { key ->
            pendingJoins.remove(key)
        }

        if (expiredKeys.isNotEmpty()) {
            println("Cleaned up ${expiredKeys.size} expired join keys")
        }
    }

    /**
     * Arrêt propre du manager
     */
    fun shutdown() {
        cleanupExecutor.shutdown()
        pendingJoins.clear()
    }

    /**
     * Obtient des statistiques
     */
    fun getStats(): JoinKeyStats {
        return JoinKeyStats(
            pendingJoins = pendingJoins.size
        )
    }
}

/**
 * Informations de join stockées temporairement
 */
data class JoinInfo(
    val joinKey: String,
    val roomId: String,
    val roomType: RoomType,
    val visible: Boolean,
    val roomData: Map<String, Any>,
    val joinData: Map<String, Any>,
    val isDevRoom: Boolean,
    val channel: ChatChannel?,
    val createdAt: Long
)

/**
 * Statistiques du JoinKeyManager
 */
data class JoinKeyStats(
    val pendingJoins: Int
)
