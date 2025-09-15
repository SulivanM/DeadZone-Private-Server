package dev.deadzone.socket.handler.save.compound.building.response

import kotlinx.serialization.Serializable

@Serializable
data class BuildingCollectResponse(
    val success: Boolean = true,
    val locked: Boolean,
    val resource: String, // point to GameResources constants
    val collected: Double,
    val remainder: Double,
    val total: Double,
    val bonus: Double, // some special bonus IDK
    val destroyed: Boolean = false
)
