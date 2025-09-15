package dev.deadzone.core.model.network

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class RemotePlayerDataConstants(val value: String)

object RemotePlayerDataConstants_Constants {
    val RELATIONSHIP_FRIEND = RemotePlayerDataConstants("friend")
    val RELATIONSHIP_NEUTRAL = RemotePlayerDataConstants("neutral")
    val RELATIONSHIP_ENEMY = RemotePlayerDataConstants("enemy")
}
