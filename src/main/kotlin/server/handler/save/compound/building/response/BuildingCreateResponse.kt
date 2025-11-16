package server.handler.save.compound.building.response

import dev.deadzone.core.model.game.data.TimerData
import kotlinx.serialization.Serializable

@Serializable
data class BuildingCreateResponse(
    val success: Boolean,
    val items: Map<String, Int>, // item id to quantity
    val timer: TimerData?,        // build timer
    val error: String = "",       // error code (e.g., "55" for not enough coins)
    val cost: Int = 0,            // cash cost for instant purchase
)
