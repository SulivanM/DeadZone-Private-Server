package dev.deadzone.core.model.game.data.quests

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.quests.DynamicQuestGoalEnum

@Serializable
data class DynamicQuestGoal(
    val type: DynamicQuestGoalEnum,
    val stat: String?,
    val survivor: String?,
    val goal: Int
)
