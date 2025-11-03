package server.handler.save.compound.building.response

import kotlinx.serialization.Serializable

@Serializable
data class BuildingSpeedUpResponse(
    val error: String,
    val success: Boolean = true,
    val cost: Int,
)
