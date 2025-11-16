package server.handler.save.compound.misc.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class RallyAssignmentResponse(
    val success: Boolean = true
): BaseResponse()
