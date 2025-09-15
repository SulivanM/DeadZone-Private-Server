package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.alliance.AllianceDataSummary

@Serializable
data class AllianceList(
    val list: List<AllianceDataSummary> = listOf()
)
