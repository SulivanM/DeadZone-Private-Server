package server.handler.save.compound.building.response

import kotlinx.serialization.Serializable

@Serializable
data class BuildingCollectResponse(
    val success: Boolean = true,
    val locked: Boolean,
    val resource: String,
    val collected: Double,
    val remainder: Double,
    val total: Double,
    val bonus: Double,
    val destroyed: Boolean = false
)
