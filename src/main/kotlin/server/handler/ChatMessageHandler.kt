package server.handler

import context.ServerContext
import server.messaging.HandlerContext
import common.Logger
import room.RoomManager
import room.chat.ChatMessageType
import room.chat.ChatRoom
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.service.BadWordFilterService

/**
 * Handler pour les messages de chat
 * Gère: sendMessage (envoi de message)
 */
class ChatMessageHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.getString("sendMessage") != null
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val userId = connection.playerId
        if (userId == "[Undetermined]") {
            Logger.warn { "Chat message from undetermined player" }
            return
        }

        // Récupérer le message
        val messageText = message.getString("sendMessage") ?: run {
            Logger.warn { "No message text in sendMessage" }
            return
        }

        // Filtrer les mots interdits
        if (BadWordFilterService.containsBadWord(messageText)) {
            Logger.warn { "Chat message from $userId blocked: contains bad words" }
            // Optionnel: envoyer une notification au joueur
            return
        }

        // Récupérer le channel (optionnel, peut être dans les metadata)
        val channelName = message.getString("channel")

        Logger.debug { "Chat message from $userId: $messageText (channel: $channelName)" }

        // Trouver la ChatRoom du joueur
        // Si un channel est spécifié, chercher cette room spécifique
        // Sinon, envoyer à toutes les ChatRooms du joueur
        val playerRooms = RoomManager.getPlayerRooms(userId)
        val chatRooms = playerRooms.filterIsInstance<ChatRoom>()

        if (chatRooms.isEmpty()) {
            Logger.warn { "Player $userId is not in any chat room" }
            return
        }

        // Déterminer le type de message
        val messageType = ChatMessageType.PUBLIC // TODO: supporter d'autres types

        // Envoyer le message à la/les room(s) appropriée(s)
        val targetRooms = if (channelName != null) {
            chatRooms.filter { it.channel.channelName == channelName }
        } else {
            chatRooms
        }

        var messageSent = false
        for (room in targetRooms) {
            if (room.processChatMessage(userId, messageText, messageType)) {
                messageSent = true
                Logger.debug { "Message sent to room ${room.roomId} (${room.channel})" }
            } else {
                Logger.warn { "Message blocked by flood protection in room ${room.roomId}" }
            }
        }

        if (!messageSent && targetRooms.isNotEmpty()) {
            // Message bloqué par flood protection
            Logger.debug { "Message from $userId was blocked by flood protection" }
        }
    }
}
