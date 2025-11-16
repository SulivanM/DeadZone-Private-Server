package room.chat

import java.util.*

/**
 * Données d'un message de chat
 * Basé sur ChatMessageData.as du client AS3
 */
data class ChatMessageData(
    val uniqueId: String = UUID.randomUUID().toString(),
    val channel: ChatChannel,
    val messageType: ChatMessageType,
    val posterId: String,
    val posterNickName: String,
    val message: String,
    val toNickName: String = "",  // Destinataire pour les messages privés
    val timestamp: Long = System.currentTimeMillis(),
    val linkData: Map<Int, String>? = null,  // Changé de Map<String, Any> à Map<Int, String> pour correspondre au format
    val allianceId: String? = null,
    val allianceTag: String? = null,
    // Customisation admin
    val adminNameColor: String? = null,
    val adminMessageColor: String? = null,
    val adminBold: Boolean = false,
    val adminItalic: Boolean = false
) {
    companion object {
        /**
         * Crée un message système
         */
        fun systemMessage(channel: ChatChannel, message: String): ChatMessageData {
            return ChatMessageData(
                channel = channel,
                messageType = ChatMessageType.SYSTEM,
                posterId = "system",
                posterNickName = "System",
                message = message
            )
        }

        /**
         * Crée un message d'avertissement
         */
        fun warningMessage(channel: ChatChannel, message: String, targetId: String): ChatMessageData {
            return ChatMessageData(
                channel = channel,
                messageType = ChatMessageType.WARNING,
                posterId = "system",
                posterNickName = "System",
                message = message
            )
        }
    }
}
