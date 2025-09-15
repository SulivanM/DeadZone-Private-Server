package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
data class AllianceLifetimeStats(
    val userName: String?,
    val points: Int,
    val wins: Int,
    val losses: Int,
    val abandons: Int,
    val defWins: Int,
    val defLosses: Int,
    val pointsAttack: Int,
    val pointsDefend: Int,
    val missionSuccess: Int,
    val missionFail: Int,
    val missionAbandon: Int,
    val pointsMission: Int
)
