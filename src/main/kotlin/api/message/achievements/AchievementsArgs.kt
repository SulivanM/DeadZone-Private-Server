package api.message.achievements

import kotlinx.serialization.Serializable

/**
 * Arguments for AchievementsProgressSet (277)
 * Sets achievement progress to a specific value
 */
@Serializable
data class AchievementsProgressSetArgs(
    val achievementId: String = "",
    val progress: Int = 0
)

/**
 * Arguments for AchievementsProgressAdd (280)
 * Adds to achievement progress (delta)
 */
@Serializable
data class AchievementsProgressAddArgs(
    val achievementId: String = "",
    val progressDelta: Int = 0
)

/**
 * Arguments for AchievementsProgressMax (283)
 * Sets achievement progress to max of current or new value
 */
@Serializable
data class AchievementsProgressMaxArgs(
    val achievementId: String = "",
    val progress: Int = 0
)

/**
 * Arguments for AchievementsProgressComplete (286)
 * Manually completes an achievement
 */
@Serializable
data class AchievementsProgressCompleteArgs(
    val achievementId: String = ""
)
