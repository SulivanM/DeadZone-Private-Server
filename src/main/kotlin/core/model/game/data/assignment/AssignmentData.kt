package dev.deadzone.core.model.game.data.assignment

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.assignment.AssignmentStageData

@Serializable
data class AssignmentData(
    val name: String,
    val id: String,
    val started: Boolean,
    val competed: Boolean,
    val stageindex: Int,
    val survivors: List<String> = listOf(),  // survivor ids
    val stagelist: List<AssignmentStageData> = listOf()
)
