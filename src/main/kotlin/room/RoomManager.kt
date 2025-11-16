package room

import room.chat.ChatChannel
import room.chat.ChatRoom
import server.core.Connection
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

/**
 * Gestionnaire centralisé de toutes les rooms
 * Singleton thread-safe
 */
object RoomManager {
    // Toutes les rooms actives (roomId -> Room)
    private val rooms = ConcurrentHashMap<String, Room>()

    // Mapping des joueurs vers leurs rooms (userId -> Set<roomId>)
    private val playerRooms = ConcurrentHashMap<String, MutableSet<String>>()

    // Service de nettoyage périodique des rooms vides
    private val cleanupExecutor = Executors.newSingleThreadScheduledExecutor()

    init {
        // Nettoyer les rooms vides toutes les 5 minutes
        cleanupExecutor.scheduleAtFixedRate({
            cleanupEmptyRooms()
        }, 5, 5, TimeUnit.MINUTES)
    }

    /**
     * Crée ou rejoint une room
     * Si la room existe, le joueur la rejoint
     * Sinon, une nouvelle room est créée
     */
    fun createOrJoinRoom(
        roomId: String,
        roomType: RoomType,
        userId: String,
        connection: Connection,
        visible: Boolean = true,
        roomData: Map<String, Any> = emptyMap(),
        joinData: Map<String, Any> = emptyMap(),
        isDevRoom: Boolean = false,
        channel: ChatChannel? = null,
        serverContext: context.ServerContext? = null
    ): Room? {
        // Stocker les joinData dans la connexion pour y accéder plus tard
        connection.joinData = joinData

        val room = rooms.computeIfAbsent(roomId) {
            // Créer la room selon son type
            when (roomType) {
                RoomType.CHAT -> {
                    val chatChannel = channel ?: ChatChannel.PUBLIC
                    ChatRoom(
                        roomId = roomId,
                        channel = chatChannel,
                        visible = visible,
                        roomData = roomData,
                        ownerId = userId,
                        isDevRoom = isDevRoom
                    )
                }
                RoomType.ALLIANCE -> {
                    // Extraire l'allianceId du roomId (format: A_{allianceId})
                    val allianceId = if (roomId.startsWith("A_")) {
                        roomId.substring(2)
                    } else {
                        roomId
                    }

                    if (serverContext == null) {
                        common.Logger.error { "Cannot create AllianceRoom without ServerContext" }
                        return@computeIfAbsent Room(
                            roomId = roomId,
                            roomType = roomType,
                            visible = visible,
                            roomData = roomData,
                            ownerId = userId,
                            isDevRoom = isDevRoom
                        )
                    }

                    room.alliance.AllianceRoom(
                        roomId = roomId,
                        allianceId = allianceId,
                        serverContext = serverContext,
                        visible = visible,
                        roomData = roomData,
                        ownerId = userId,
                        isDevRoom = isDevRoom
                    )
                }
                else -> {
                    Room(
                        roomId = roomId,
                        roomType = roomType,
                        visible = visible,
                        roomData = roomData,
                        ownerId = userId,
                        isDevRoom = isDevRoom
                    )
                }
            }
        }

        // Ajouter le joueur à la room
        val joined = room.addPlayer(userId, connection)
        if (joined) {
            // Enregistrer que le joueur est dans cette room
            playerRooms.computeIfAbsent(userId) { ConcurrentHashMap.newKeySet() }.add(roomId)
            return room
        }

        return null
    }

    /**
     * Fait quitter une room à un joueur
     */
    fun leaveRoom(roomId: String, userId: String): Boolean {
        val room = rooms[roomId] ?: return false

        val left = room.removePlayer(userId)
        if (left) {
            // Retirer de la liste des rooms du joueur
            playerRooms[userId]?.remove(roomId)
            if (playerRooms[userId]?.isEmpty() == true) {
                playerRooms.remove(userId)
            }

            // Si la room est vide, la supprimer
            if (room.isEmpty) {
                removeRoom(roomId)
            }

            return true
        }

        return false
    }

    /**
     * Fait quitter toutes les rooms à un joueur
     */
    fun leaveAllRooms(userId: String) {
        val userRoomIds = playerRooms[userId]?.toList() ?: return

        userRoomIds.forEach { roomId ->
            leaveRoom(roomId, userId)
        }
    }

    /**
     * Obtient une room par son ID
     */
    fun getRoom(roomId: String): Room? {
        return rooms[roomId]
    }

    /**
     * Obtient une ChatRoom par son ID
     */
    fun getChatRoom(roomId: String): ChatRoom? {
        return rooms[roomId] as? ChatRoom
    }

    /**
     * Liste toutes les rooms d'un certain type
     */
    fun listRoomsByType(
        roomType: RoomType,
        visibleOnly: Boolean = true,
        devRoomsOnly: Boolean = false
    ): List<RoomInfo> {
        return rooms.values
            .filter { room ->
                room.roomType == roomType &&
                        (!visibleOnly || room.visible) &&
                        (!devRoomsOnly || room.isDevRoom == devRoomsOnly)
            }
            .map { room ->
                RoomInfo(
                    id = room.roomId,
                    roomType = room.roomType.typeName,
                    onlineUsers = room.playerCount,
                    roomData = room.roomData
                )
            }
    }

    /**
     * Trouve une room avec de la place pour un type donné
     * Utilisé pour le load balancing des rooms publiques
     */
    fun findAvailableRoom(
        roomType: RoomType,
        devRoomsOnly: Boolean = false
    ): Room? {
        return rooms.values
            .filter { room ->
                room.roomType == roomType &&
                        !room.isFull &&
                        !room.locked &&
                        room.visible &&
                        room.isDevRoom == devRoomsOnly
            }
            .minByOrNull { it.playerCount }
    }

    /**
     * Crée un ID de room unique
     */
    fun generateRoomId(prefix: String = "room"): String {
        return "$prefix-${UUID.randomUUID()}"
    }

    /**
     * Obtient toutes les rooms d'un joueur
     */
    fun getPlayerRooms(userId: String): List<Room> {
        val roomIds = playerRooms[userId] ?: return emptyList()
        return roomIds.mapNotNull { rooms[it] }
    }

    /**
     * Vérifie si un joueur est dans une room
     */
    fun isPlayerInRoom(userId: String, roomId: String): Boolean {
        return playerRooms[userId]?.contains(roomId) == true
    }

    /**
     * Supprime une room
     */
    fun removeRoom(roomId: String) {
        val room = rooms.remove(roomId)
        room?.cleanup()

        // Retirer de toutes les listes de joueurs
        playerRooms.forEach { (_, roomIds) ->
            roomIds.remove(roomId)
        }
    }

    /**
     * Nettoie les rooms vides (appelé périodiquement)
     */
    private fun cleanupEmptyRooms() {
        val emptyRoomIds = rooms.entries
            .filter { (_, room) ->
                room.isEmpty && System.currentTimeMillis() - room.lastActivityAt > TimeUnit.MINUTES.toMillis(10)
            }
            .map { it.key }

        emptyRoomIds.forEach { roomId ->
            println("Cleaning up empty room: $roomId")
            removeRoom(roomId)
        }
    }

    /**
     * Obtient des statistiques sur les rooms
     */
    fun getStats(): RoomStats {
        val totalRooms = rooms.size
        val totalPlayers = playerRooms.size
        val roomsByType = rooms.values.groupBy { it.roomType }
            .mapValues { it.value.size }

        return RoomStats(
            totalRooms = totalRooms,
            totalPlayers = totalPlayers,
            roomsByType = roomsByType
        )
    }

    /**
     * Arrêt propre du manager
     */
    fun shutdown() {
        cleanupExecutor.shutdown()
        rooms.values.forEach { it.cleanup() }
        rooms.clear()
        playerRooms.clear()
    }
}

/**
 * Informations sur une room pour les listings
 */
data class RoomInfo(
    val id: String,
    val roomType: String,
    val onlineUsers: Int,
    val roomData: Map<String, Any>
)

/**
 * Statistiques du RoomManager
 */
data class RoomStats(
    val totalRooms: Int,
    val totalPlayers: Int,
    val roomsByType: Map<RoomType, Int>
)
