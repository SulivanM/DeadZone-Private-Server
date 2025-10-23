package server.handler.save.mission.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

/**
 * Get zombie response (mis_zombies)
 *
 * @property max server spawning is disabled if set to false
 */
@Serializable
data class GetZombieResponse(
    val z: List<String>,
    val max: Boolean = false,
): BaseResponse()
