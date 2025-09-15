package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.alliance.AllianceMember

@Serializable
data class AllianceMemberList(
    val list: List<AllianceMember>
)
