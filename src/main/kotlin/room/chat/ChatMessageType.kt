package room.chat

/**
 * Types de messages chat
 * Basé sur ChatSystem.as du client AS3
 */
enum class ChatMessageType(val typeName: String) {
    PUBLIC("public"),
    PRIVATE("private"),
    SYSTEM("system"),
    WARNING("warning"),
    COMMAND("command"),
    TRADE_REQUEST("tradeRequest"),
    TRADE_FEEDBACK("tradeFeedback"),
    ADMIN_PUBLIC("adminPublic"),
    ADMIN_PRIVATE("adminPrivate"),
    ALLIANCE_INVITE("allianceInvite"),
    ALLIANCE_FEEDBACK("allianceFeedback");

    companion object {
        fun fromTypeName(name: String): ChatMessageType? {
            return values().find { it.typeName == name }
        }
    }
}
