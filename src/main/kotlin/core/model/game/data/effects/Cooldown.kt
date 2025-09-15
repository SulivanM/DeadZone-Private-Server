package dev.deadzone.core.model.game.data.effects

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.TimerData

@Serializable
data class Cooldown(
    val raw: ByteArray,  // see readObject of Cooldown
    val id: String,
    val type: UInt,
    val subType: String,
    val timer: TimerData
)
