package dev.deadzone.core.model.game.data.raid

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.assignment.AssignmentData

@Serializable
data class RaidData(
    val assignmentData: AssignmentData,
    val ptsPerSurvivor: Int,
    val maxSurvivorMissionPoints: Int,
    val points: Int
)
