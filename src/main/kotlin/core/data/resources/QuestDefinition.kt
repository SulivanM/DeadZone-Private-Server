package core.data.resources

import core.model.game.data.GameResources

/**
 * Quest definition parsed from XML
 */
data class QuestDefinition(
    val id: String,
    val type: String,
    val level: Int,
    val important: Boolean = false,
    val secret: Int = 0,
    val timeBased: Boolean = false,
    val startImageUri: String? = null,
    val completeImageUri: String? = null,
    val startTime: Long? = null,
    val endTime: Long? = null,
    val visible: Boolean = true,
    val silent: Boolean = false,
    val prerequisites: List<QuestPrerequisite> = emptyList(),
    val goals: List<QuestGoal> = emptyList(),
    val rewards: List<QuestReward> = emptyList()
)

/**
 * Quest prerequisite - references other quests that must be completed
 */
data class QuestPrerequisite(
    val questIds: List<String> // At least one of these must be completed
)

/**
 * Quest goal/condition
 */
data class QuestGoal(
    val type: GoalType,
    val id: String? = null,
    val value: Int = 0,
    val level: Int? = null,
    val description: String? = null
)

enum class GoalType {
    STAT,           // Stat id (zombieKills, etc.)
    LEVEL,          // Player level (lvl)
    BUILDING,       // Building id (bld)
    SURVIVOR,       // Survivor class (srv)
    ITEM,           // Item id (itm)
    RESOURCE,       // Resource id (res)
    TUTORIAL,       // Tutorial completion (tut)
    TASK            // Task id (task)
}

/**
 * Quest reward
 */
data class QuestReward(
    val type: RewardType,
    val id: String? = null,
    val value: Int = 0,
    val minLevel: Int? = null,
    val maxLevel: Int? = null,
    val percentage: Double? = null,
    val itemXml: String? = null // For complex item rewards
)

enum class RewardType {
    XP,             // XP points
    XP_PERC,        // XP percentage based on level
    ITEM,           // Item reward
    RESOURCE        // Resource reward
}

/**
 * Achievement definition (similar to Quest but for repeatable in-mission achievements)
 */
data class AchievementDefinition(
    val id: String,
    val mission: Boolean = false,
    val min: Int = 0,
    val time: Double = 0.0,
    val xp: Int = 0,
    val xpPerc: Double = 0.0,
    val xpLevelMultiplier: Double? = null,
    val limitPerMission: Int? = null,
    val percentage: Boolean = false
)

/**
 * Dynamic quest configuration from XML
 */
data class DynamicQuestConfig(
    val statId: String,
    val rarity: Int,
    val levelMin: Int,
    val levelMax: Int,
    val min: Int,
    val max: Int,
    val minLevelMultiplier: Double? = null,
    val maxLevelMultiplier: Double? = null,
    val xp: Double,
    val xpLevelMultiplier: Double? = null,
    val morale: Double,
    val moraleLevelMultiplier: Double? = null
)
