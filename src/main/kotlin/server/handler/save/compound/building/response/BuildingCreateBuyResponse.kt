package server.handler.save.compound.building.response

import kotlinx.serialization.Serializable

@Serializable
data class BuildingCreateBuyResponse(
    val success: Boolean,
    
    val levelPts: Int? = null,
)
