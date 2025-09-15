package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
data class AllianceDataSummary(
    val allianceId: String?,
    val name: String?,
    val tag: String?,
    val banner: String?,  // can also be bytearray. if a string, will try to decodeToByteArray
    val thumbURI: String?,
    val memberCount: Int?,
    val efficiency: Double?,
    val points: Int?
)
