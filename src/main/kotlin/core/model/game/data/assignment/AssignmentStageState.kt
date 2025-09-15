package dev.deadzone.core.model.game.data.assignment

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class AssignmentStageState(val value: UInt)

object AssignmentStageState_Constants {
    val LOCKED = AssignmentStageState(0u)
    val ACTIVE = AssignmentStageState(1u)
    val COMPLETE = AssignmentStageState(2u)
}
