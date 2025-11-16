package room

import server.core.Connection
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.locks.ReentrantReadWriteLock
import kotlin.concurrent.read
import kotlin.concurrent.write

/**
 * Classe de base représentant une room (salle) dans le jeu
 * Peut être utilisée pour GAME, CHAT, TRADE, ALLIANCE rooms
 */
open class Room(
    val roomId: String,
    val roomType: RoomType,
    val visible: Boolean = true,
    val roomData: Map<String, Any> = emptyMap(),
    val ownerId: String? = null,
    val isDevRoom: Boolean = false,
    val maxPlayers: Int = 100
) {
    // Connexions des joueurs dans cette room (userId -> Connection)
    private val connections = ConcurrentHashMap<String, Connection>()

    // Lock pour les opérations thread-safe
    private val lock = ReentrantReadWriteLock()

    // Timestamp de création
    val createdAt: Long = System.currentTimeMillis()

    // Timestamp de dernière activité
    var lastActivityAt: Long = System.currentTimeMillis()
        private set

    // Room verrouillée (pas de nouveaux joueurs)
    var locked: Boolean = false
        private set

    /**
     * Nombre de joueurs actuellement dans la room
     */
    val playerCount: Int
        get() = connections.size

    /**
     * Vérifie si la room est pleine
     */
    val isFull: Boolean
        get() = playerCount >= maxPlayers

    /**
     * Vérifie si la room est vide
     */
    val isEmpty: Boolean
        get() = connections.isEmpty()

    /**
     * Ajoute un joueur à la room
     * @return true si ajouté avec succès, false si la room est pleine ou verrouillée
     */
    open fun addPlayer(userId: String, connection: Connection): Boolean {
        return lock.write {
            if (locked || isFull) {
                return@write false
            }
            connections[userId] = connection
            lastActivityAt = System.currentTimeMillis()
            onPlayerJoined(userId, connection)
            true
        }
    }

    /**
     * Retire un joueur de la room
     */
    open fun removePlayer(userId: String): Boolean {
        return lock.write {
            val connection = connections.remove(userId)
            if (connection != null) {
                lastActivityAt = System.currentTimeMillis()
                onPlayerLeft(userId, connection)
                true
            } else {
                false
            }
        }
    }

    /**
     * Obtient une connexion par userId
     */
    fun getConnection(userId: String): Connection? {
        return lock.read {
            connections[userId]
        }
    }

    /**
     * Obtient toutes les connexions
     */
    fun getAllConnections(): List<Connection> {
        return lock.read {
            connections.values.toList()
        }
    }

    /**
     * Obtient tous les userIds
     */
    fun getAllUserIds(): List<String> {
        return lock.read {
            connections.keys.toList()
        }
    }

    /**
     * Vérifie si un joueur est dans la room
     */
    fun hasPlayer(userId: String): Boolean {
        return lock.read {
            connections.containsKey(userId)
        }
    }

    /**
     * Envoie un message à tous les joueurs de la room
     */
    fun broadcast(message: api.message.Message) {
        lock.read {
            connections.values.forEach { connection ->
                try {
                    connection.send(message)
                } catch (e: Exception) {
                    println("Error broadcasting to connection: ${e.message}")
                }
            }
        }
    }

    /**
     * Envoie un message à tous les joueurs sauf un
     */
    fun broadcastExcept(message: api.message.Message, excludeUserId: String) {
        lock.read {
            connections.forEach { (userId, connection) ->
                if (userId != excludeUserId) {
                    try {
                        connection.send(message)
                    } catch (e: Exception) {
                        println("Error broadcasting to connection: ${e.message}")
                    }
                }
            }
        }
    }

    /**
     * Verrouille la room (empêche les nouveaux joueurs de rejoindre)
     */
    open fun lockRoom() {
        lock.write {
            locked = true
        }
    }

    /**
     * Déverrouille la room
     */
    open fun unlockRoom() {
        lock.write {
            locked = false
        }
    }

    /**
     * Appelé quand un joueur rejoint la room
     * Peut être override par les sous-classes
     */
    protected open fun onPlayerJoined(userId: String, connection: Connection) {
        // Override dans les sous-classes
    }

    /**
     * Appelé quand un joueur quitte la room
     * Peut être override par les sous-classes
     */
    protected open fun onPlayerLeft(userId: String, connection: Connection) {
        // Override dans les sous-classes
    }

    /**
     * Nettoie les ressources de la room
     */
    open fun cleanup() {
        lock.write {
            connections.clear()
        }
    }

    override fun toString(): String {
        return "Room(id=$roomId, type=$roomType, players=$playerCount/$maxPlayers, visible=$visible, locked=$locked)"
    }
}
