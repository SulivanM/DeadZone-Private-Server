package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.alliance.AllianceMessage

@Serializable
data class AllianceMessageList(
    val list: List<AllianceMessage> = listOf()
)
