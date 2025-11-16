package room.chat

/**
 * Données d'un utilisateur dans un chat room
 * Basé sur ChatUserData.as du client AS3
 */
data class ChatUserData(
    val nickName: String,
    val userId: String,
    var level: Int = 1,
    var online: Boolean = true,
    var allianceId: String = "",
    var allianceTag: String = "",
    var isAdmin: Boolean = false
) {
    /**
     * Met à jour les informations de l'utilisateur
     */
    fun updateInfo(
        level: Int? = null,
        allianceId: String? = null,
        allianceTag: String? = null,
        online: Boolean? = null
    ) {
        level?.let { this.level = it }
        allianceId?.let { this.allianceId = it }
        allianceTag?.let { this.allianceTag = it }
        online?.let { this.online = it }
    }
}
