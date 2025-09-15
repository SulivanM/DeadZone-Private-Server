package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
data class AllianceMember(
    val playerId: String,
    val nickname: String,
    val level: Int,
    val joindate: Long,
    val rank: UInt,
    val tokens: UInt,
    val online: Boolean,
    val points: UInt,
    val pointsAttack: UInt,
    val pointsDefend: UInt,
    val pointsMission: UInt,
    val efficiency: Double,
    val wins: Int,
    val losses: Int,
    val abandons: Int,
    val defWins: Int,
    val defLosses: Int,
    val missionSuccess: Int,
    val missionFail: Int,
    val missionAbandon: Int,
    val missionEfficiency: Double,
    val raidWinPts: UInt,
    val raidLosePts: UInt
)
