package core.model.game.data.alliance

import kotlinx.serialization.Serializable
import core.model.game.data.alliance.AllianceMember

@Serializable
data class AllianceMemberList(
    val list: List<AllianceMember>
)
