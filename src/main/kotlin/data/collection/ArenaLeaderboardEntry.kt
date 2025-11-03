package data.collection

import kotlinx.serialization.Serializable

@Serializable
data class ArenaLeaderboardEntry(
    val playerId: String,
    val playerName: String,
    val arenaName: String,
    val level: Int,
    val points: Int,
    val timestamp: Long
)
