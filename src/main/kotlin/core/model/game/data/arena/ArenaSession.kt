package dev.deadzone.core.model.game.data.arena

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.assignment.AssignmentStageState

@Serializable
data class ArenaSession(
    val points: Int,
    val state: Map<String, AssignmentStageState> = mapOf()
)
