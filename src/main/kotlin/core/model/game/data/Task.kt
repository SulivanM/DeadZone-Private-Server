package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.core.items.model.Item

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
