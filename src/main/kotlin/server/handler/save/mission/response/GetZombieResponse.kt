package server.handler.save.mission.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class GetZombieResponse(
    val z: List<String>,
    val max: Boolean = false,
): BaseResponse()
