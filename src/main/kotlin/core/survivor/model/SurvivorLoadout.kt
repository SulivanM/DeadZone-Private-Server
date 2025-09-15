package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.Survivor
import dev.deadzone.core.model.game.data.SurvivorLoadoutData

@Serializable
data class SurvivorLoadout(
    val type: String,
    val survivor: Survivor,
    val weapon: SurvivorLoadoutData,
    val gearPassive: SurvivorLoadoutData,
    val gearActive: SurvivorLoadoutData,
    val supressChanges: Boolean = false
)
