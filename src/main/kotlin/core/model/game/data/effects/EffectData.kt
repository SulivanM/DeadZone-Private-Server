package dev.deadzone.core.model.game.data.effects

import kotlinx.serialization.Serializable

@Serializable
data class EffectData(
    val type: UInt,
    val value: Double
)
