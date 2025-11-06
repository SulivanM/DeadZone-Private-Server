package server.handler.save.survivor.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class PlayerCustomResponse(
    
    val error: String? = null,

    val attributes: List<String> = emptyList(),

    val levelPts: Int? = null,

    val cooldown: String? = null,
): BaseResponse()
