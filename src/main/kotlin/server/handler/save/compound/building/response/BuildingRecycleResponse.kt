package server.handler.save.compound.building.response

import kotlinx.serialization.Serializable

@Serializable
data class BuildingRecycleResponse(
    val success: Boolean,
    val items: Map<String, Int>,
)
