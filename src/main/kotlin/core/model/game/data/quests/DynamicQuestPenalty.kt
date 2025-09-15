package dev.deadzone.core.model.game.data.quests

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.quests.DynamicQuestPenaltyEnum
import dev.deadzone.core.model.game.data.MoraleConstants

@Serializable
data class DynamicQuestPenalty(
    val type: DynamicQuestPenaltyEnum,
    val value: String, // actually string and int
    val moraleType: MoraleConstants?,  // Only if type == "morale"
)
