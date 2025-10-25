package server.handler.save.survivor.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class SurvivorClassResponse(
    val success: Boolean = true,
    val error: String? = null
): BaseResponse()
