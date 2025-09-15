package dev.deadzone.core.model.data.user

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.data.user.AbstractUser
import dev.deadzone.core.model.data.user.PublishingNetworkProfile

@Serializable
data class PlayerIOUser(
    val abstractUser: AbstractUser,
    val profile: PublishingNetworkProfile
)
