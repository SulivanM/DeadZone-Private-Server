package server.handler.save.bounty.response

import kotlinx.serialization.Serializable

@Serializable
data class BountySpeedUpResponse(
    val error: String = "",
    val success: Boolean = true,
    val cost: Int = 0
)
