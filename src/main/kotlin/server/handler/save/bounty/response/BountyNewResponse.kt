package server.handler.save.bounty.response

import core.model.game.data.bounty.InfectedBounty
import kotlinx.serialization.Serializable

@Serializable
data class BountyNewResponse(
    val error: String = "",
    val success: Boolean = true,
    val bounty: InfectedBounty? = null,
    val nextIssue: Long? = null
)
