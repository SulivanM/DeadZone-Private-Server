package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class AllianceRankPrivilege(val value: UInt)

object AllianceRankPrivilege_Constants {
    val None = AllianceRankPrivilege(0u)
    val ChangeLeadership = AllianceRankPrivilege(1u)
    val Disband = AllianceRankPrivilege(2u)
    val PostMessages = AllianceRankPrivilege(4u)
    val DeleteMessages = AllianceRankPrivilege(8u)
    val InviteMembers = AllianceRankPrivilege(16u)
    val RemoveMembers = AllianceRankPrivilege(32u)
    val PromoteMembers = AllianceRankPrivilege(64u)
    val DemoteMembers = AllianceRankPrivilege(128u)
    val SpendTokens = AllianceRankPrivilege(256u)
    val EditRankNames = AllianceRankPrivilege(512u)
    val EditBanner = AllianceRankPrivilege(1024u)
    val All = AllianceRankPrivilege(1048575u)
}
