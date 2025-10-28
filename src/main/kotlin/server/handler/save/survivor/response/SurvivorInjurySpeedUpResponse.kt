package server.handler.save.survivor.response

import kotlinx.serialization.Serializable

@Serializable
data class SurvivorInjurySpeedUpResponse(
    val error: String = "",
    val success: Boolean = true,
    val cost: Int = 0
)
