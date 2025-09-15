package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class DamageType(
    val UNKNOWN: UInt = 0u,
    val MELEE: UInt = 1u,
    val PROJECTILE: UInt = 2u,
    val EXPLOSIVE: UInt = 3u
)
