package core.model.game.data

import kotlinx.serialization.Serializable
import core.items.model.Item

@Serializable
data class Task(
    val id: String,
    val type: String,
    val length: Int,
    val time: Double,
    val items: List<Item>?,
    val completed: Boolean,
    val survivors: List<String>,  // survivor ids
)
