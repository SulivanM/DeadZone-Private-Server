package core.model.game.data

import kotlinx.serialization.Serializable
import core.items.model.Item

@Serializable
data class BatchRecycleJob(
    val id: String,
    val items: List<Item>,
    val start: Long,
    val end: Int
)
