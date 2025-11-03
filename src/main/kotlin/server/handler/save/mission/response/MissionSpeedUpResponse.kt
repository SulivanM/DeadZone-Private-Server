package server.handler.save.mission.response

import kotlinx.serialization.Serializable

@Serializable
data class MissionSpeedUpResponse(
    val error: String,
    val success: Boolean = true,
    val cost: Int,
)
