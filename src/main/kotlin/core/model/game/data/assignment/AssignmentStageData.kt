package dev.deadzone.core.model.game.data.assignment

import kotlinx.serialization.Serializable

@Serializable
data class AssignmentStageData(
    val level: Int,
    val time: Int,
    val state: Int,
    val srvcount: Int
)
