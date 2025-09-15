package dev.deadzone.core.model.game.data.task

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.JunkBuilding
import dev.deadzone.core.model.game.data.Task

@Serializable
data class JunkRemovalTask(
    val task: Task,
    val target: JunkBuilding,
    val targetId: String,  // obtained from buildingId
    val buildingId: String,
    val xp: Int = 0
)
