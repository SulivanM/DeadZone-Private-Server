package core.model.game.data.quests

import kotlinx.serialization.Serializable

@Serializable
enum class QuestAttributeType(val value: String) {
    
    STAT_INC("statInc"),
    XP_INC("xpInc"),

    XP("xp"),
    ITEM("itm"),
    MORALE_REWARD("morale"),

    MORALE_PENALTY("morale");

    companion object {
        fun fromValue(value: String): QuestAttributeType? {
            return entries.find { it.value == value }
        }
    }
}
