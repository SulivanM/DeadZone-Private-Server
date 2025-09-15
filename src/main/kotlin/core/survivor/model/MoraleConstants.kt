package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class MoraleConstants(val value: String)

object MoraleConstants_Constants {
    val EFFECT_INJURY = MoraleConstants("injury")
    val EFFECT_MISSION_COMPLETE = MoraleConstants("missionComplete")
    val EFFECT_FOOD = MoraleConstants("food")
    val EFFECT_WATER = MoraleConstants("water")
    val EFFECT_SECURITY = MoraleConstants("security")
    val EFFECT_COMFORT = MoraleConstants("comfort")
    val EFFECT_AVERAGE_SURVIVOR = MoraleConstants("avgSurvivor")
    val EFFECT_DAILY_QUEST_COMPLETED = MoraleConstants("dailyQuestCompleted")
    val EFFECT_DAILY_QUEST_FAILED = MoraleConstants("dailyQuestFailed")
}
