package core.model.game.data.quests

import core.model.game.data.MoraleConstants
import kotlinx.serialization.Serializable

@Serializable
data class QuestAttribute(
    val category: QuestAttributeCategory,
    val type: String,
    val stat: String? = null,
    val survivor: String? = null,
    val intValue: Int? = null,
    val stringValue: String? = null,
    val doubleValue: Double? = null,
    val moraleType: MoraleConstants? = null
) {
    companion object {
        
        fun createStatIncGoal(stat: String, goal: Int): QuestAttribute {
            return QuestAttribute(
                category = QuestAttributeCategory.GOAL,
                type = QuestAttributeType.STAT_INC.value,
                stat = stat,
                intValue = goal
            )
        }

        fun createXpIncGoal(survivor: String, goal: Int): QuestAttribute {
            return QuestAttribute(
                category = QuestAttributeCategory.GOAL,
                type = QuestAttributeType.XP_INC.value,
                survivor = survivor,
                intValue = goal
            )
        }

        fun createXpReward(amount: Int): QuestAttribute {
            return QuestAttribute(
                category = QuestAttributeCategory.REWARD,
                type = QuestAttributeType.XP.value,
                intValue = amount
            )
        }

        fun createItemReward(itemXml: String): QuestAttribute {
            return QuestAttribute(
                category = QuestAttributeCategory.REWARD,
                type = QuestAttributeType.ITEM.value,
                stringValue = itemXml
            )
        }

        fun createMoraleReward(moraleType: MoraleConstants, amount: Double): QuestAttribute {
            return QuestAttribute(
                category = QuestAttributeCategory.REWARD,
                type = QuestAttributeType.MORALE_REWARD.value,
                moraleType = moraleType,
                doubleValue = amount
            )
        }

        fun createMoralePenalty(moraleType: MoraleConstants, amount: Double): QuestAttribute {
            return QuestAttribute(
                category = QuestAttributeCategory.PENALTY,
                type = QuestAttributeType.MORALE_PENALTY.value,
                moraleType = moraleType,
                doubleValue = amount
            )
        }
    }

    val goal: Int get() = intValue ?: 0
    val amount: Int get() = intValue ?: 0
    val value: Double get() = doubleValue ?: 0.0
}
