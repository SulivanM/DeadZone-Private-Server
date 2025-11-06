package core.model.game.data.quests

import kotlinx.serialization.Serializable

@Serializable
enum class QuestAttributeCategory(val value: String) {
    GOAL("goal"),
    REWARD("reward"),
    PENALTY("penalty");

    companion object {
        fun fromValue(value: String): QuestAttributeCategory? {
            return entries.find { it.value == value }
        }
    }
}
