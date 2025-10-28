package server.handler.save.mission.response

import kotlinx.serialization.Serializable

@Serializable
data class MissionSpeedUpResponse(
    val error: String, // not enough fuel error: PlayerIOError.NotEnoughCoins.errorID
    val success: Boolean = true,
    val cost: Int,
)
