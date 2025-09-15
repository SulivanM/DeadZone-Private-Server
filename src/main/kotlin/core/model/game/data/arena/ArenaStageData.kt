package dev.deadzone.core.model.game.data.arena

import kotlinx.serialization.Serializable

@Serializable
data class ArenaStageData(
    val srvpoints: Int,
    val objpoints: Int
)
