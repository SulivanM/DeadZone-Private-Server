package server.handler.save.survivor.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class SurvivorRenameResponse(
    val success: Boolean = true,
    val error: String? = null,
    val name: String? = null,
    val id: String? = null
): BaseResponse()
