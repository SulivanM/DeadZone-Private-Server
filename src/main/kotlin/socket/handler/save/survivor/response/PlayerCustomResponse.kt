package dev.deadzone.socket.handler.save.survivor.response

import dev.deadzone.socket.handler.save.BaseResponse
import kotlinx.serialization.Serializable

/**
 * Any update to player's leader, such as create leader, respec
 */
@Serializable
data class PlayerCustomResponse(
    // only if error
    val error: String? = null,

    // list of string which is AttributesConstants
    // likely used when leader respec skill
    val attributes: List<String> = emptyList(),

    // likely used when respec and there is extra level point??
    val levelPts: Int? = null,

    // base64 string, likely change name cooldown
    val cooldown: String? = null,
): BaseResponse()