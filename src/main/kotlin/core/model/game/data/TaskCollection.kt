package core.model.game.data

import kotlinx.serialization.Serializable
import core.model.game.data.Task

@Serializable
data class TaskCollection(
    val list: List<Task> = listOf()
)
