package dev.deadzone.api.message.social

import kotlinx.serialization.Serializable

@Serializable
data class SocialRefreshOutput(
    val myProfile: SocialProfile = SocialProfile(),
    val friends: List<SocialProfile> = emptyList(),
    val blocked: String = "",
) {
    companion object {
        fun admin(): SocialRefreshOutput {
            return SocialRefreshOutput(
                myProfile = SocialProfile.admin(),
                friends = listOf(SocialProfile.admin()),
                blocked = "No one"
            )
        }
    }
}
