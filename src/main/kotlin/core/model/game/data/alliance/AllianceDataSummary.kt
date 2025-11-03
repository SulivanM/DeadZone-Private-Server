package core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
data class AllianceDataSummary(
    val allianceId: String?,
    val name: String?,
    val tag: String?,
    val banner: String?,
    val thumbURI: String?,
    val memberCount: Int?,
    val efficiency: Double?,
    val points: Int?
)
