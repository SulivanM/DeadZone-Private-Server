package server.handler.save.survivor.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class SurvivorHealResponse(
    val success: Boolean = true,
    val error: String? = null,
    val cost: Int = 0
): BaseResponse()
