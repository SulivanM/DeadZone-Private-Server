package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class TaskStatus(val value: String)

object TaskStatus_Constants {
    val ACTIVE = TaskStatus("active")
    val INACTIVE = TaskStatus("inactive")
    val COMPLETE = TaskStatus("complete")
}
