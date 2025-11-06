package core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
data class AllianceLifetimeStats(
    val userName: String? = null,
    val points: Int = 0,
    val wins: Int = 0,
    val losses: Int = 0,
    val abandons: Int = 0,
    val defWins: Int = 0,
    val defLosses: Int = 0,
    val pointsAttack: Int = 0,
    val pointsDefend: Int = 0,
    val missionSuccess: Int = 0,
    val missionFail: Int = 0,
    val missionAbandon: Int = 0,
    val pointsMission: Int = 0,
    val kills: Int = 0,
    val deaths: Int = 0,
    val roundsParticipated: Int = 0,
    val tokensEarned: Int = 0,
    val tasksCompleted: Int = 0,
    val highestRank: Int = 0
)
