package api.message.achievements

import kotlinx.serialization.Serializable

/**
 * Error response for Achievements API calls
 */
@Serializable
data class AchievementsProgressSetError(
    val errorCode: Int = 0,
    val message: String = ""
)

@Serializable
data class AchievementsProgressAddError(
    val errorCode: Int = 0,
    val message: String = ""
)

@Serializable
data class AchievementsProgressMaxError(
    val errorCode: Int = 0,
    val message: String = ""
)

@Serializable
data class AchievementsProgressCompleteError(
    val errorCode: Int = 0,
    val message: String = ""
)
