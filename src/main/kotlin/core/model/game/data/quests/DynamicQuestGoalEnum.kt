package dev.deadzone.core.model.game.data.quests

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class DynamicQuestGoalEnum(val value: String)

object DynamicQuestGoalEnum_Constants {
    val statInc = DynamicQuestGoalEnum("statInc")
    val xpInc = DynamicQuestGoalEnum("xpInc")
}
