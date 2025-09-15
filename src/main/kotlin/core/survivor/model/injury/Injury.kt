package dev.deadzone.core.survivor.model.injury

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.TimerData

@Serializable
data class Injury(
    val id: String,
    val type: String,
    val location: String,
    val severity: String,
    val damage: Double,
    val morale: Double,
    val timer: TimerData?
)
