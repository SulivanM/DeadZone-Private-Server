package server.handler.save.bounty.response

import kotlinx.serialization.Serializable

@Serializable
data class BountyAddResponse(
    val error: String = "",
    val success: Boolean = true,
    val amount: Int = 0,
    val total: Int = 0
)
