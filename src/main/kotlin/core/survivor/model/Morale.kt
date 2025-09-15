package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class Morale(
    val maps: Map<String, Double> = mapOf()
)
