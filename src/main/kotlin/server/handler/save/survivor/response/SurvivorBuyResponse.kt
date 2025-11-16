package server.handler.save.survivor.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable
import core.model.game.data.Survivor

@Serializable
data class SurvivorBuyResponse(
    val success: Boolean = true,
    val error: String? = null,
    val cost: Int = 0,
    val survivor: Survivor? = null
): BaseResponse()
