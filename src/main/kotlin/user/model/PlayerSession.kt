package user.model

data class PlayerSession(
    val playerId: String,
    val token: String,
    val issuedAt: Long,
    var expiresAt: Long,
    var lifetime: Long,
)
