package user.model

import kotlinx.serialization.Serializable

@Serializable
data class UserProfile(
    val playerId: String,
    val email: String = "",
    val displayName: String,
    val avatarUrl: String,
    val createdAt: Long,
    val lastLogin: Long,
    val countryCode: String? = null,
    val friends: Set<UserProfile> = emptySet(),
    val enemies: Set<UserProfile> = emptySet(),
)