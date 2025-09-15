package dev.deadzone.core.model.game.data.quests

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class DynamicQuestPenaltyEnum(val value: String)

object DynamicQuestPenaltyEnum_Constants {
    val morale = DynamicQuestPenaltyEnum("morale")
}
