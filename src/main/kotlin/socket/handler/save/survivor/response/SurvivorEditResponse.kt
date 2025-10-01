package socket.handler.save.survivor.response

import socket.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class SurvivorEditResponse(
    val success: Boolean = true
): BaseResponse()