package server.handler.save.survivor.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class SurvivorLoadoutResponse(
    val success: Boolean = true,
    val bind: List<String>? = null
): BaseResponse()
