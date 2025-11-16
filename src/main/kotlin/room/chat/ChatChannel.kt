package room.chat

/**
 * Canaux de chat disponibles
 * Basé sur ChatSystem.as du client AS3
 */
enum class ChatChannel(val channelName: String) {
    PUBLIC("public"),
    PRIVATE("private"),
    TRADE_PUBLIC("tradePublic"),
    RECRUITING("recruiting"),
    ALLIANCE("alliance"),
    ADMIN("admin"),
    ALL("all"); // Canal virtuel pour broadcast

    companion object {
        fun fromChannelName(name: String): ChatChannel? {
            return values().find { it.channelName == name }
        }
    }
}
