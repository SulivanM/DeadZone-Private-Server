package server.handler.save.survivor.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

/**
 * Any update to player's leader, such as create leader, respec
 */
@Serializable
data class PlayerCustomResponse(
    // only if error
    val error: String? = null,

    // Attributes map used for attribute upgrades and respec
    // Format: {"combatProjectile": 1.2, "health": 120.0, ...}
    val attributes: Map<String, Double>? = null,

    // likely used when respec and there is extra level point??
    val levelPts: Int? = null,

    // base64 string, likely change name cooldown
    val cooldown: String? = null,
): BaseResponse()