package server.handler.save.survivor.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class SurvivorEditResponse(
    val success: Boolean = true
): BaseResponse()