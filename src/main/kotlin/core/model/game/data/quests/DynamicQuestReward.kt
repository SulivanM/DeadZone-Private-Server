package dev.deadzone.core.model.game.data.quests

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.quests.DynamicQuestRewardEnum
import dev.deadzone.core.model.game.data.MoraleConstants

@Serializable
data class DynamicQuestReward(
    val type: DynamicQuestRewardEnum,
    val value: String, // actually string and integer
    val moraleType: MoraleConstants?,  // Only if type == "morale"
)
