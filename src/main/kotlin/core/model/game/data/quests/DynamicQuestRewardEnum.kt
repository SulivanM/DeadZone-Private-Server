package dev.deadzone.core.model.game.data.quests

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class DynamicQuestRewardEnum(val value: String)

object DynamicQuestRewardEnum_Constants {
    val xp = DynamicQuestRewardEnum("xp")
    val itm = DynamicQuestRewardEnum("itm")
    val morale = DynamicQuestRewardEnum("morale")
}
