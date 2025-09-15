package dev.deadzone.api.message.social

import dev.deadzone.core.data.AdminData
import io.ktor.util.date.getTimeMillis
import kotlinx.serialization.Serializable

@Serializable
data class SocialProfile(
    val userId: String = "",
    val displayName: String = "",
    val avatarUrl: String = "",
    val lastOnline: Long = 0,
    val countryCode: String = "",
    val userToken: String = "",
) {
    companion object {
        fun admin(): SocialProfile {
            return SocialProfile(
                userId = AdminData.PLAYER_ID,
                displayName = AdminData.DISPLAY_NAME,
                avatarUrl = AdminData.AVATAR_URL,
                lastOnline = getTimeMillis() - (1000L * 2000),
                countryCode = AdminData.COUNTRY_CODE,
                userToken = AdminData.TOKEN,
            )
        }
    }
}
