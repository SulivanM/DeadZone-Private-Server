package dev.deadzone.core.model.data.user

import kotlinx.serialization.Serializable

@Serializable
data class PublishingNetworkProfile(
    val userId: String,
    val displayName: String,
    val avatarUrl: String,
    val lastOnline: Long,
    val countryCode: String
)
