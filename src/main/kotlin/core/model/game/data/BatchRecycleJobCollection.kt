package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.BatchRecycleJob

@Serializable
data class BatchRecycleJobCollection(
    val list: List<BatchRecycleJob> = listOf()
)
