package server.handler.save.survivor.response

import core.survivor.model.injury.Injury
import kotlinx.serialization.Serializable

@Serializable
data class SurvivorInjureResponse(
    val success: Boolean = true,
    val srv: String? = null,
    val inj: Injury? = null
)
