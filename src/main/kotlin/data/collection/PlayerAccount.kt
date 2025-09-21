package data.collection

import core.data.AdminData
import io.ktor.util.date.getTimeMillis
import kotlinx.serialization.Serializable

@Serializable
data class PlayerAccount(
    val playerId: String,
    val hashedPassword: String,
    val email: String = "",
    val displayName: String,
    val avatarUrl: String,
    val createdAt: Long,
    val lastLogin: Long,
    val countryCode: String? = null,
    val serverMetadata: ServerMetadata,
) {
    companion object {
        fun admin(): PlayerAccount {
            return PlayerAccount(
                playerId = AdminData.PLAYER_ID,
                hashedPassword = AdminData.PASSWORD,
                email = AdminData.EMAIL,
                displayName = AdminData.DISPLAY_NAME,
                avatarUrl = AdminData.AVATAR_URL,
                createdAt = getTimeMillis(),
                lastLogin = getTimeMillis(),
                countryCode = AdminData.COUNTRY_CODE,
                serverMetadata = ServerMetadata()
            )
        }
    }
}

@Serializable
data class ServerMetadata(
    val notes: String? = null,
    val flags: Map<String, Boolean> = emptyMap(),
    val extra: Map<String, String> = emptyMap(),
)