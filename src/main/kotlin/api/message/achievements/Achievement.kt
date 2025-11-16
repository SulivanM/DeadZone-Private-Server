package api.message.achievements

import kotlinx.serialization.Serializable

/**
 * Achievement data returned to client
 */
@Serializable
data class Achievement(
    val identifier: String = "",
    val title: String = "",
    val description: String = "",
    val imageUrl: String = "",
    val progressGoal: UInt = 0u,
    val progress: UInt = 0u,
    val lastUpdated: Double = 0.0
)
