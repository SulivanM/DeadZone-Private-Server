package api.message.achievements

import kotlinx.serialization.Serializable

/**
 * Output for AchievementsProgressSet (277)
 */
@Serializable
data class AchievementsProgressSetOutput(
    val achievement: Achievement = Achievement(),
    val completedNow: Boolean = false
)

/**
 * Output for AchievementsProgressAdd (280)
 */
@Serializable
data class AchievementsProgressAddOutput(
    val achievement: Achievement = Achievement(),
    val completedNow: Boolean = false
)

/**
 * Output for AchievementsProgressMax (283)
 */
@Serializable
data class AchievementsProgressMaxOutput(
    val achievement: Achievement = Achievement(),
    val completedNow: Boolean = false
)

/**
 * Output for AchievementsProgressComplete (286)
 */
@Serializable
data class AchievementsProgressCompleteOutput(
    val achievement: Achievement = Achievement(),
    val completedNow: Boolean = false
)
