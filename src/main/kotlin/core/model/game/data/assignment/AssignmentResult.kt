package dev.deadzone.core.model.game.data.assignment

import kotlinx.serialization.Serializable

@Serializable
data class AssignmentResult(
    val id: String,
    val type: String = AssignmentType_Constants.None.value
)
