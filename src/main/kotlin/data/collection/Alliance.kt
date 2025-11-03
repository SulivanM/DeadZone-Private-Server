package data.collection

import kotlinx.serialization.Serializable

@Serializable
data class Alliance(
    val allianceId: String,
    val name: String,
    val tag: String,
    val bannerBytes: String? = null,
    val thumbImage: String? = null,
    val createdAt: Long,
    val createdBy: String,
    val memberCount: Int = 0,
    val totalPoints: Int = 0,
    val dataJson: String? = null
)

@Serializable
data class AllianceMember(
    val allianceId: String,
    val playerId: String,
    val joinedAt: Long,
    val rank: Int = 0,
    val lifetimeStats: core.model.game.data.alliance.AllianceLifetimeStats? = null
)
