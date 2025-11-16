package server.handler.save.survivor.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable
import core.survivor.model.injury.Injury

@Serializable
data class SurvivorInjureResponse(
    val success: Boolean = true,
    val srv: String? = null,  // survivor id
    val inj: Injury? = null   // injury data (null if no injury was applied)
): BaseResponse()
