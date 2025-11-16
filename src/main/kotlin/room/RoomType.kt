package room

/**
 * Types de rooms disponibles dans le jeu
 * Basé sur RoomType.as du client AS3
 */
enum class RoomType(val typeName: String) {
    GAME("TLS-DeadZone-Game-28"),
    CHAT("ChatRoom-14"),
    TRADE("TradeRoom-10"),
    ALLIANCE("Alliance-6");

    companion object {
        fun fromTypeName(typeName: String): RoomType? {
            return values().find { it.typeName == typeName }
        }
    }
}
