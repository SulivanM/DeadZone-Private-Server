package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class TaskType(val value: String)

object TaskType_Constants {
    val JUNK_REMOVAL = TaskType("junk_removal")
    val ITEM_CRAFTING = TaskType("item_crafting")
}
