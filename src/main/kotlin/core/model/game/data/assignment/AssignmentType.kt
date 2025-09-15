package dev.deadzone.core.model.game.data.assignment

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class AssignmentType(val value: String)

object AssignmentType_Constants {
    val None = AssignmentType("None")
    val Raid = AssignmentType("Raid")
    val Arena = AssignmentType("Arena")
}
