package dev.deadzone.socket.handler.save.compound.building.response

import kotlinx.serialization.Serializable

@Serializable
data class BuildingSpeedUpResponse(
    val error: String, // not enough fuel error: PlayerIOError.NotEnoughCoins.errorID
    val success: Boolean = true,
    val cost: Int,
)
