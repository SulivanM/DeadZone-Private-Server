package core.model.game.data.alliance

import kotlinx.serialization.Serializable
import core.model.game.data.alliance.AllianceMessage

@Serializable
data class AllianceMessageList(
    val list: List<AllianceMessage> = listOf()
)
