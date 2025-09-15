package dev.deadzone.core.model.game.data.research

import kotlinx.serialization.Serializable

@Serializable
data class ResearchTask(
    val start: Long,
    val id: String,
    val length: Int,
    val category: String,
    val group: String,
    val level: Int,
    val completed: Boolean,
)
