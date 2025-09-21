package core.model.game.data.assignment

import kotlinx.serialization.Serializable
import core.model.game.data.assignment.AssignmentData

@Serializable
data class AssignmentCollection(
    val list: List<AssignmentData> = listOf()
)
