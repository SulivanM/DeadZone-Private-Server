package server.handler

import context.ServerContext
import server.messaging.HandlerContext
import common.Logger
import room.RoomManager
import room.chat.ChatMessageType
import room.chat.ChatRoom
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler

/**
 * Handler pour les messages des ChatRooms
 * Gère tous les messages envoyés par le client AS3 depuis ChatRoom.as
 */
class ChatRoomMessageHandler(private val serverContext: ServerContext) : SocketMessageHandler {

    companion object {
        // Types connus de messages de ChatRoom
        private val KNOWN_TYPES = setOf(
            "chatMsg", "allianceUpdate", "levelUpdate", "sendCommand",
            "warning", "unfilteredMsg", "adminFeedback", "report",
            "banConsume", "ban", "prvtOnline", "disconnectUser",
            "lock", "unlock"
        )
    }

    /**
     * Vérifie si le message a un type explicite en première position
     * Ceci est nécessaire car certains messages ont un nombre pair d'éléments,
     * ce qui empêche l'extraction automatique du type par SocketMessage
     */
    private fun hasExplicitType(message: SocketMessage): Boolean {
        val firstElement = message.getRaw().firstOrNull() as? String
        return firstElement != null && KNOWN_TYPES.contains(firstElement)
    }
    override fun match(message: SocketMessage): Boolean {
        // Match sur le type de message
        // Pour les messages au format positionnel (quand raw.size est pair),
        // on doit vérifier le premier élément du raw car message.type sera null
        val type = message.type ?: (message.getRaw().firstOrNull() as? String)
        return when (type) {
            "chatMsg" -> true
            "allianceUpdate" -> true
            "levelUpdate" -> true
            "sendCommand" -> true
            "warning" -> true
            "unfilteredMsg" -> true
            "adminFeedback" -> true
            "report" -> true
            "banConsume" -> true
            "ban" -> true
            "prvtOnline" -> true
            "disconnectUser" -> true
            "lock" -> true
            "unlock" -> true
            else -> false
        }
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val userId = connection.playerId
        if (userId == "[Undetermined]") {
            Logger.warn { "ChatRoom message from undetermined player" }
            return
        }

        // Utiliser la même logique de récupération du type que dans match()
        val type = message.type ?: (message.getRaw().firstOrNull() as? String)

        when (type) {
            "chatMsg" -> handleChatMessage(userId, message)
            "allianceUpdate" -> handleAllianceUpdate(userId, message)
            "levelUpdate" -> handleLevelUpdate(userId, message)
            "sendCommand" -> handleSendCommand(userId, message)
            "warning" -> handleWarning(userId, message)
            "unfilteredMsg" -> handleUnfilteredMessage(userId, message)
            "adminFeedback" -> handleAdminFeedback(userId, message)
            "report" -> handleReport(userId, message)
            "banConsume" -> handleBanConsume(userId, message)
            "ban" -> handleBan(userId, message)
            "prvtOnline" -> handlePrivateOnline(userId, message)
            "disconnectUser" -> handleDisconnectUser(userId, message)
            "lock" -> handleLockUnlock(userId, message, true)
            "unlock" -> handleLockUnlock(userId, message, false)
        }
    }

    /**
     * Traite un message de chat
     * Format attendu (ChatRoom.as ligne 209-222):
     * createMessage(SM_CHAT_MSG, param1, param3, param2) où:
     * - param1 (index 0): messageType (ex: "public", "private", etc.)
     * - param3 (index 1): message (le texte du message)
     * - param2 (index 2): toNickName (destinataire, vide pour messages publics)
     * - puis add(linkData.length) puis chaque linkData
     */
    private fun handleChatMessage(userId: String, message: SocketMessage) {
        // Utiliser getRaw() directement pour éviter les problèmes d'offset
        val raw = message.getRaw()
        val offset = if (hasExplicitType(message)) 1 else 0

        // Lire dans le bon ordre selon le client AS3
        val messageType = raw.getOrNull(offset) as? String ?: "public"
        val messageText = raw.getOrNull(offset + 1) as? String ?: ""
        val toNickName = raw.getOrNull(offset + 2) as? String ?: ""

        // Lire les linkData
        val linkDataCount = (raw.getOrNull(offset + 3) as? Number)?.toInt() ?: 0
        val linkData = mutableListOf<String>()
        for (i in 0 until linkDataCount) {
            val linkItem = raw.getOrNull(offset + 4 + i) as? String
            if (linkItem != null) {
                linkData.add(linkItem)
            }
        }

        Logger.debug { "Chat message from $userId: \"$messageText\" (type: $messageType, to: $toNickName, linkData: ${linkData.size})" }

        // Trouver la ChatRoom du joueur
        val playerRooms = RoomManager.getPlayerRooms(userId)
        val chatRooms = playerRooms.filterIsInstance<ChatRoom>()

        if (chatRooms.isEmpty()) {
            Logger.warn { "Player $userId is not in any chat room" }
            return
        }

        // Déterminer le type de message selon le messageType
        // Le client envoie les types tels que définis dans ChatSystem.as
        val chatMessageType = ChatMessageType.fromTypeName(messageType) ?: run {
            Logger.warn { "Unknown message type: $messageType, defaulting to PUBLIC" }
            ChatMessageType.PUBLIC
        }

        // Pour les messages privés, on ne traite qu'une room
        // Pour les messages publics, on envoie à toutes les ChatRooms du joueur
        val targetRooms = when (chatMessageType) {
            ChatMessageType.PRIVATE, ChatMessageType.ADMIN_PRIVATE -> {
                // Message privé: trouver la bonne room (typiquement la room de chat privé)
                chatRooms.take(1)
            }
            else -> {
                // Message public/alliance/trade: envoyer à toutes les rooms appropriées
                chatRooms
            }
        }

        for (room in targetRooms) {
            // Passer le message avec les linkData
            if (room.processChatMessage(userId, messageText, chatMessageType, toNickName, linkData)) {
                Logger.debug { "Message sent to room ${room.roomId} (${room.channel.channelName})" }
            } else {
                Logger.warn { "Message blocked in room ${room.roomId}" }
            }
        }
    }

    /**
     * Traite une mise à jour d'alliance
     * Format attendu (ChatRoom.as ligne 389, 404):
     * - String: allianceId
     * - String: allianceTag
     */
    private fun handleAllianceUpdate(userId: String, message: SocketMessage) {
        val raw = message.getRaw()
        val offset = if (hasExplicitType(message)) 1 else 0

        val allianceId = raw.getOrNull(offset) as? String ?: ""
        val allianceTag = raw.getOrNull(offset + 1) as? String ?: ""

        Logger.debug { "Alliance update from $userId: allianceId=$allianceId, tag=$allianceTag" }

        // Mettre à jour dans toutes les ChatRooms du joueur
        val playerRooms = RoomManager.getPlayerRooms(userId)
        val chatRooms = playerRooms.filterIsInstance<ChatRoom>()

        for (room in chatRooms) {
            room.updateUserAlliance(userId, allianceId, allianceTag)
            Logger.debug { "Alliance updated in room ${room.roomId}" }
        }
    }

    /**
     * Traite une mise à jour de niveau
     * Format attendu (ChatRoom.as ligne 626):
     * - Int: level
     */
    private fun handleLevelUpdate(userId: String, message: SocketMessage) {
        val raw = message.getRaw()
        val offset = if (hasExplicitType(message)) 1 else 0

        val level = (raw.getOrNull(offset) as? Number)?.toInt() ?: 1

        Logger.debug { "Level update from $userId: level=$level" }

        // Mettre à jour dans toutes les ChatRooms du joueur
        val playerRooms = RoomManager.getPlayerRooms(userId)
        val chatRooms = playerRooms.filterIsInstance<ChatRoom>()

        for (room in chatRooms) {
            room.updateUserLevel(userId, level)
            Logger.debug { "Level updated in room ${room.roomId}" }
        }
    }

    /**
     * Traite une commande envoyée
     * Format attendu (ChatRoom.as ligne 256-266):
     * - String: targetUser (param2)
     * - String: command (param1)
     * - [String...]: arguments
     */
    private fun handleSendCommand(userId: String, message: SocketMessage) {
        val raw = message.getRaw()
        val offset = if (hasExplicitType(message)) 1 else 0

        val targetUser = raw.getOrNull(offset) as? String ?: ""
        val command = raw.getOrNull(offset + 1) as? String ?: ""

        Logger.debug { "Command from $userId: command=$command, targetUser=$targetUser" }

        // TODO: implémenter la logique de commande
        // Pour l'instant, on log simplement
    }

    /**
     * Traite un avertissement
     * Format attendu (ChatRoom.as ligne 227):
     * - String: targetNickName
     */
    private fun handleWarning(userId: String, message: SocketMessage) {
        val raw = message.getRaw()
        val offset = if (hasExplicitType(message)) 1 else 0

        val targetNickName = raw.getOrNull(offset) as? String ?: ""

        Logger.debug { "Warning from $userId to $targetNickName" }

        // TODO: implémenter la logique d'avertissement
    }

    /**
     * Traite un message non filtré
     * Format attendu (ChatRoom.as ligne 237):
     * - String: param1
     * - String: param2
     * - String: param3
     * - String: param4
     */
    private fun handleUnfilteredMessage(userId: String, message: SocketMessage) {
        Logger.debug { "Unfiltered message from $userId" }
        // TODO: implémenter la logique
    }

    /**
     * Traite un feedback admin
     * Format attendu (ChatRoom.as ligne 246):
     * - String: feedback
     */
    private fun handleAdminFeedback(userId: String, message: SocketMessage) {
        val raw = message.getRaw()
        val offset = if (hasExplicitType(message)) 1 else 0

        val feedback = raw.getOrNull(offset) as? String ?: ""
        Logger.debug { "Admin feedback from $userId: $feedback" }
        // TODO: implémenter la logique
    }

    /**
     * Traite un rapport
     * Format attendu (ChatRoom.as ligne 275):
     * - String: param1
     * - String: param2
     * - String: param3
     * - String: param4
     * - String: param5
     */
    private fun handleReport(userId: String, message: SocketMessage) {
        Logger.debug { "Report from $userId" }
        // TODO: implémenter la logique de rapport
    }

    /**
     * Traite la consommation d'un ban
     * Format attendu (ChatRoom.as ligne 285):
     * (pas de paramètres)
     */
    private fun handleBanConsume(userId: String, message: SocketMessage) {
        Logger.debug { "Ban consume from $userId" }
        // TODO: implémenter la logique
    }

    /**
     * Traite une demande de ban
     * Format attendu (ChatRoom.as ligne 297-310):
     * - String: banType
     * - Boolean: silent
     * - String: targetUser
     * - String: duration
     * - String: reason
     * - String: extra
     */
    private fun handleBan(userId: String, message: SocketMessage) {
        Logger.debug { "Ban request from $userId" }
        // TODO: implémenter la logique de ban
    }

    /**
     * Traite le changement de statut privé en ligne
     * Format attendu (ChatRoom.as ligne 324):
     * - Boolean: online
     */
    private fun handlePrivateOnline(userId: String, message: SocketMessage) {
        val raw = message.getRaw()
        val offset = if (hasExplicitType(message)) 1 else 0

        val online = raw.getOrNull(offset) as? Boolean ?: true
        Logger.debug { "Private online status from $userId: $online" }
        // TODO: implémenter la logique
    }

    /**
     * Traite la déconnexion d'un utilisateur
     * Format attendu (ChatRoom.as ligne 333):
     * - String: targetNickName
     */
    private fun handleDisconnectUser(userId: String, message: SocketMessage) {
        val raw = message.getRaw()
        val offset = if (hasExplicitType(message)) 1 else 0

        val targetNickName = raw.getOrNull(offset) as? String ?: ""
        Logger.debug { "Disconnect user request from $userId for $targetNickName" }
        // TODO: implémenter la logique
    }

    /**
     * Traite le verrouillage/déverrouillage du chat
     * Format attendu (ChatRoom.as ligne 342):
     * (pas de paramètres)
     */
    private fun handleLockUnlock(userId: String, message: SocketMessage, lock: Boolean) {
        Logger.debug { "Lock/unlock request from $userId: lock=$lock" }

        val playerRooms = RoomManager.getPlayerRooms(userId)
        val chatRooms = playerRooms.filterIsInstance<ChatRoom>()

        for (room in chatRooms) {
            if (lock) {
                room.lockRoom()
            } else {
                room.unlockRoom()
            }
            Logger.debug { "Room ${room.roomId} ${if (lock) "locked" else "unlocked"}" }
        }
    }
}
