package room.chat

import api.message.Message
import room.Room
import room.RoomType
import server.core.Connection
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.locks.ReentrantReadWriteLock
import kotlin.concurrent.read
import kotlin.concurrent.write

/**
 * Room spécialisée pour le chat
 * Basé sur ChatRoom.as du client AS3
 */
class ChatRoom(
    roomId: String,
    val channel: ChatChannel,
    visible: Boolean = true,
    roomData: Map<String, Any> = emptyMap(),
    ownerId: String? = null,
    isDevRoom: Boolean = false,
    maxPlayers: Int = 100
) : Room(
    roomId = roomId,
    roomType = RoomType.CHAT,
    visible = visible,
    roomData = roomData,
    ownerId = ownerId,
    isDevRoom = isDevRoom,
    maxPlayers = maxPlayers
) {
    // Utilisateurs dans le chat room (userId -> ChatUserData)
    private val users = ConcurrentHashMap<String, ChatUserData>()

    // Historique des messages (limité aux derniers messages)
    private val messageHistory = mutableListOf<ChatMessageData>()
    private val messageHistoryLock = ReentrantReadWriteLock()
    private val maxMessageHistory = 100

    // Flood protection: timestamp du dernier message par utilisateur
    private val lastMessageTime = ConcurrentHashMap<String, Long>()
    private val messageCount = ConcurrentHashMap<String, Int>()
    private val floodBannedUsers = ConcurrentHashMap<String, Long>() // userId -> ban expiration timestamp

    // Configuration flood protection
    private val minMessageInterval = 500L // 500ms entre chaque message
    private val maxMessagesPerWindow = 5 // 5 messages max
    private val floodWindowDuration = 5000L // dans une fenêtre de 5 secondes
    private val floodBanDuration = 60000L // ban de 60 secondes

    // État du chat (verrouillé/déverrouillé)
    @Volatile
    private var isLocked: Boolean = false

    /**
     * Ajoute un utilisateur au chat room
     */
    override fun addPlayer(userId: String, connection: Connection): Boolean {
        val added = super.addPlayer(userId, connection)
        if (added) {
            // Créer les données utilisateur à partir des données de connexion
            val joinData = connection.joinData
            // Le client AS3 envoie level + 1 (voir ChatRoom.as lignes 143 et 169)
            // On doit donc soustraire 1 pour obtenir le vrai level
            val clientLevel = (joinData["level"] as? Number)?.toInt() ?: 1
            val actualLevel = if (clientLevel > 0) clientLevel - 1 else 0

            val userData = ChatUserData(
                nickName = joinData["nickName"] as? String ?: "Unknown",
                userId = userId,
                level = actualLevel,
                online = true,
                allianceId = joinData["allianceId"] as? String ?: "",
                allianceTag = joinData["allianceTag"] as? String ?: "",
                isAdmin = false // TODO: vérifier les droits admin
            )
            users[userId] = userData

            // NE PAS envoyer initialJoin ici - sera envoyé après joinresult par JoinHandler
            // pour éviter un problème de timing (le client enregistre les handlers après joinresult)

            // Notifier les autres joueurs
            notifyPlayerJoined(userData)
        }
        return added
    }

    /**
     * Envoie le message initialJoin à un joueur
     * Appelé par JoinHandler après l'envoi de joinresult
     */
    fun sendInitialJoinToPlayer(userId: String) {
        val userData = users[userId] ?: return
        val connection = getConnection(userId) ?: return
        sendInitialJoin(connection, userData)
    }

    /**
     * Retire un utilisateur du chat room
     */
    override fun removePlayer(userId: String): Boolean {
        val removed = super.removePlayer(userId)
        if (removed) {
            val userData = users.remove(userId)
            if (userData != null) {
                // Nettoyer les données de flood protection
                lastMessageTime.remove(userId)
                messageCount.remove(userId)
                floodBannedUsers.remove(userId)

                // Notifier les autres joueurs
                notifyPlayerLeft(userData)
            }
        }
        return removed
    }

    /**
     * Envoie le message d'initialisation au joueur qui rejoint
     * Format attendu par le client AS3 (ChatRoom.as ligne 407-428):
     * - UInt: nombre d'utilisateurs
     * - Pour chaque utilisateur:
     *   - String: userId
     *   - String: nickName
     *   - Int: level
     *   - String: allianceId
     *   - String: allianceTag
     *   - Boolean: isAdmin
     */
    private fun sendInitialJoin(connection: Connection, userData: ChatUserData) {
        val message = Message("initialJoin")

        // Ajouter le nombre d'utilisateurs
        val usersList = users.values.toList()
        message.add(usersList.size.toUInt())

        // Ajouter chaque utilisateur dans l'ordre attendu par le client
        usersList.forEach { user ->
            message.add(user.userId)        // String
            message.add(user.nickName)      // String
            message.add(user.level)         // Int
            message.add(user.allianceId)    // String
            message.add(user.allianceTag)   // String
            message.add(user.isAdmin)       // Boolean
        }

        connection.send(message)

        // Envoyer l'historique des messages récents
        messageHistoryLock.read {
            messageHistory.takeLast(20).forEach { msgData ->
                sendChatMessage(connection, msgData)
            }
        }
    }

    /**
     * Notifie tous les joueurs qu'un nouveau joueur a rejoint
     * Format attendu par le client AS3 (ChatRoom.as ligne 442-464):
     * - String: userId
     * - String: nickName
     * - Int: level
     * - String: allianceId
     * - String: allianceTag
     * - Boolean: isAdmin
     */
    private fun notifyPlayerJoined(userData: ChatUserData) {
        val message = Message("playerJoined")
        message.add(userData.userId)        // String
        message.add(userData.nickName)      // String
        message.add(userData.level)         // Int
        message.add(userData.allianceId)    // String
        message.add(userData.allianceTag)   // String
        message.add(userData.isAdmin)       // Boolean

        broadcastExcept(message, userData.userId)
    }

    /**
     * Notifie tous les joueurs qu'un joueur est parti
     * Format attendu par le client AS3 (ChatRoom.as ligne 477):
     * - String: userId
     */
    private fun notifyPlayerLeft(userData: ChatUserData) {
        val message = Message("playerLeft")
        message.add(userData.userId)    // String

        broadcast(message)
    }

    /**
     * Traite un message de chat
     * @return true si le message a été envoyé, false si bloqué (flood, ban, etc.)
     */
    fun processChatMessage(
        userId: String,
        messageText: String,
        messageType: ChatMessageType = ChatMessageType.PUBLIC,
        toNickName: String = "",
        linkData: List<String> = emptyList()
    ): Boolean {
        // Vérifier si le chat est verrouillé (sauf pour les admins)
        if (isLocked) {
            val userData = users[userId]
            if (userData?.isAdmin != true) {
                // Chat verrouillé et l'utilisateur n'est pas admin
                return false
            }
        }

        // Vérifier si l'utilisateur est ban pour flood
        val banExpiration = floodBannedUsers[userId]
        if (banExpiration != null) {
            if (System.currentTimeMillis() < banExpiration) {
                // Toujours banni
                return false
            } else {
                // Ban expiré
                floodBannedUsers.remove(userId)
                messageCount.remove(userId)
            }
        }

        // Vérifier flood protection
        val now = System.currentTimeMillis()
        val lastTime = lastMessageTime[userId] ?: 0L

        if (now - lastTime < minMessageInterval) {
            // Message trop rapide
            incrementFloodCounter(userId)
            return false
        }

        // Vérifier le nombre de messages dans la fenêtre
        val count = messageCount[userId] ?: 0
        if (count >= maxMessagesPerWindow) {
            val firstMessageTime = lastTime - floodWindowDuration
            if (now - firstMessageTime < floodWindowDuration) {
                // Trop de messages dans la fenêtre, ban temporaire
                floodBanUser(userId)
                return false
            } else {
                // Fenêtre expirée, reset
                messageCount[userId] = 0
            }
        }

        // Message valide
        lastMessageTime[userId] = now
        messageCount[userId] = count + 1

        // Créer et envoyer le message
        val userData = users[userId] ?: return false

        // Convertir linkData en Map si nécessaire
        val linkDataMap = if (linkData.isNotEmpty()) {
            linkData.mapIndexed { index, data -> index to data }.toMap()
        } else null

        val chatMessage = ChatMessageData(
            channel = channel,
            messageType = messageType,
            posterId = userId,
            posterNickName = userData.nickName,
            message = messageText,
            toNickName = toNickName,
            allianceId = userData.allianceId,
            allianceTag = userData.allianceTag,
            linkData = linkDataMap
        )

        // Ajouter à l'historique
        messageHistoryLock.write {
            messageHistory.add(chatMessage)
            if (messageHistory.size > maxMessageHistory) {
                messageHistory.removeAt(0)
            }
        }

        // Broadcast le message
        broadcastChatMessage(chatMessage)

        return true
    }

    /**
     * Incrémente le compteur de flood et potentiellement ban l'utilisateur
     */
    private fun incrementFloodCounter(userId: String) {
        val count = messageCount.getOrDefault(userId, 0) + 1
        messageCount[userId] = count

        if (count >= maxMessagesPerWindow * 2) {
            floodBanUser(userId)
        }
    }

    /**
     * Ban temporairement un utilisateur pour flood
     * Format attendu par le client AS3 (ChatRoom.as ligne 588-591):
     * - UInt: duration (en secondes)
     */
    private fun floodBanUser(userId: String) {
        val banExpiration = System.currentTimeMillis() + floodBanDuration
        floodBannedUsers[userId] = banExpiration

        // Notifier l'utilisateur
        val connection = getConnection(userId)
        if (connection != null) {
            val message = Message("floodBan")
            message.add((floodBanDuration / 1000).toUInt()) // UInt: duration en secondes
            connection.send(message)
        }
    }

    /**
     * Envoie un message de chat à tous les joueurs
     */
    private fun broadcastChatMessage(chatMessage: ChatMessageData) {
        getAllConnections().forEach { connection ->
            sendChatMessage(connection, chatMessage)
        }
    }

    /**
     * Envoie un message de chat à une connexion spécifique
     * Format attendu par le client AS3 (ChatRoom.as ligne 510-553):
     * - String: uniqueId
     * - String: messageType
     * - String: posterId
     * - String: posterNickName
     * - Boolean: posterIsAdmin
     * - String: toNickName (vide pour messages publics)
     * - String: message
     * - Si messageType est ADMIN_PRIVATE ou ADMIN_PUBLIC:
     *   - String: customNickName
     *   - String: customNameColor
     *   - String: customMsgColor
     * - UInt: nombre de linkData
     * - Pour chaque linkData: String
     */
    private fun sendChatMessage(connection: Connection, chatMessage: ChatMessageData) {
        val message = Message("chatMsg")

        // Récupérer les infos de l'utilisateur pour l'isAdmin
        val posterUser = users[chatMessage.posterId]
        val posterIsAdmin = posterUser?.isAdmin ?: false

        // Données de base dans l'ordre attendu par le client
        message.add(chatMessage.uniqueId)                       // String: uniqueId
        message.add(chatMessage.messageType.typeName)           // String: messageType
        message.add(chatMessage.posterId)                       // String: posterId
        message.add(chatMessage.posterNickName)                 // String: posterNickName
        message.add(posterIsAdmin)                              // Boolean: posterIsAdmin
        message.add("")                                         // String: toNickName (vide pour messages publics)
        message.add(chatMessage.message)                        // String: message

        // Customisation admin si c'est un message admin
        val isAdminMessage = chatMessage.messageType.typeName == "admin_private" ||
                             chatMessage.messageType.typeName == "admin_public"
        if (isAdminMessage) {
            message.add(chatMessage.adminNameColor ?: "")       // String: customNickName (note: erreur dans le code original, devrait être customNameColor)
            message.add(chatMessage.adminNameColor ?: "")       // String: customNameColor
            message.add(chatMessage.adminMessageColor ?: "")    // String: customMsgColor
        }

        // Link data
        val linkDataList = chatMessage.linkData?.values?.toList() ?: emptyList()
        message.add(linkDataList.size.toUInt())                 // UInt: nombre de linkData
        linkDataList.forEach { linkItem ->
            message.add(linkItem.toString())                    // String: chaque linkData
        }

        connection.send(message)
    }

    /**
     * Met à jour le niveau d'un utilisateur
     * Format attendu par le client AS3 (ChatRoom.as ligne 629-637):
     * - String: nickName (pas userId!)
     * - Int: level
     */
    fun updateUserLevel(userId: String, level: Int) {
        val userData = users[userId] ?: return
        userData.level = level

        val message = Message("levelUpdate")
        message.add(userData.nickName)  // String: nickName
        message.add(level)              // Int: level

        broadcast(message)
    }

    /**
     * Met à jour l'alliance d'un utilisateur
     * Format attendu par le client AS3 (ChatRoom.as ligne 639-648):
     * - String: nickName (pas userId!)
     * - String: allianceId
     * - String: allianceTag
     */
    fun updateUserAlliance(userId: String, allianceId: String, allianceTag: String) {
        val userData = users[userId] ?: return
        userData.allianceId = allianceId
        userData.allianceTag = allianceTag

        val message = Message("allianceUpdate")
        message.add(userData.nickName)  // String: nickName
        message.add(allianceId)         // String: allianceId
        message.add(allianceTag)        // String: allianceTag

        broadcast(message)
    }

    /**
     * Envoie un message système à tous les joueurs
     */
    fun sendSystemMessage(messageText: String) {
        val chatMessage = ChatMessageData.systemMessage(channel, messageText)

        messageHistoryLock.write {
            messageHistory.add(chatMessage)
            if (messageHistory.size > maxMessageHistory) {
                messageHistory.removeAt(0)
            }
        }

        broadcastChatMessage(chatMessage)
    }

    /**
     * Envoie un message d'avertissement à un utilisateur spécifique
     * Format attendu par le client AS3 (ChatRoom.as ligne 555-561):
     * - String: message
     */
    fun sendWarningToUser(userId: String, warningText: String) {
        val connection = getConnection(userId) ?: return

        val message = Message("warningPersonal")
        message.add(warningText)    // String: message

        connection.send(message)
    }

    /**
     * Obtient les données d'un utilisateur
     */
    fun getUserData(userId: String): ChatUserData? {
        return users[userId]
    }

    /**
     * Obtient tous les utilisateurs
     */
    fun getAllUsers(): List<ChatUserData> {
        return users.values.toList()
    }

    /**
     * Verrouille le chat (empêche les non-admins d'envoyer des messages)
     * Format attendu par le client AS3 (ChatRoom.as ligne 604-608):
     * Message "lock" sans paramètres
     */
    override fun lockRoom() {
        if (!isLocked) {
            isLocked = true
            val message = api.message.Message("lock")
            broadcast(message)
        }
    }

    /**
     * Déverrouille le chat
     * Format attendu par le client AS3 (ChatRoom.as ligne 604-608):
     * Message "unlock" sans paramètres
     */
    override fun unlockRoom() {
        if (isLocked) {
            isLocked = false
            val message = api.message.Message("unlock")
            broadcast(message)
        }
    }

    override fun cleanup() {
        super.cleanup()
        users.clear()
        messageHistoryLock.write {
            messageHistory.clear()
        }
        lastMessageTime.clear()
        messageCount.clear()
        floodBannedUsers.clear()
    }
}
