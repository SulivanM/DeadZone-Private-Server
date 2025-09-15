package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class AmmoType(
    val NONE: UInt = 0u,
    val ARROW: UInt = 1u,
    val ASSAULT_RIFLE: UInt = 2u,
    val BOLT: UInt = 4u,
    val LONG_RIFLE: UInt = 8u,
    val PISTOL: UInt = 16u,
    val SHOTGUN: UInt = 32u,
    val SMG: UInt = 64u
)
