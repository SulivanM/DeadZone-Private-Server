package core.model.data.user

import kotlinx.serialization.Serializable
import core.model.data.user.AbstractUser
import core.model.data.user.PublishingNetworkProfile

@Serializable
data class PlayerIOUser(
    val abstractUser: AbstractUser,
    val profile: PublishingNetworkProfile
)
