package dev.deadzone.socket.handler.save.compound.building.response

import dev.deadzone.core.model.game.data.TimerData
import kotlinx.serialization.Serializable

@Serializable
data class BuildingCreateResponse(
    val success: Boolean,
    val items: Map<String, Int>, // item id to quantity
    val timer: TimerData,        // build timer
)
