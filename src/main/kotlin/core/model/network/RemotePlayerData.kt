package dev.deadzone.core.model.network

import kotlinx.serialization.Serializable

@Serializable
data class RemotePlayerData(
    val name: String?,
    val nickname: String?,
    val level: Int?,
    val serviceUserId: String?,
    val serviceAvatar: String?,
    val serviceAvatarURL: String?,
    val lastLogin: Long?,
    val allianceId: String?,
    val allianceTag: String?,
    val allianceName: String?,
    val bounty: Int?,
    val bountyAllTime: Int?,
    val bountyAllTimeCount: Int?,
    val bountyEarnings: Int?,
    val bountyCollectCount: Int?,
    val bountyDate: Long?,
    val online: Boolean?,
    val onlineTimestamp: Long?,
    val raidLockout: Long?,
    val underAttack: Boolean?,
    val protected: Boolean?,
    val protected_start: Long?,
    val protected_length: Int?,
    val banned: Boolean?
)
