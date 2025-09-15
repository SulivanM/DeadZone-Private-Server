package dev.deadzone.socket.handler.save.compound.building.response

import dev.deadzone.core.model.game.data.TimerData
import kotlinx.serialization.Serializable

@Serializable
data class BuildingRepairResponse(
    val success: Boolean = true,
    val items: Map<String, Int>? = emptyMap(),
    val timer: TimerData
)
