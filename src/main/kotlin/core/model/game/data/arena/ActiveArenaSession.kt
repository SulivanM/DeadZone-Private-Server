package core.model.game.data.arena

import kotlinx.serialization.Serializable

@Serializable
data class ActiveArenaSession(
    val id: String,  
    val playerId: String,
    val arenaName: String,
    val currentStageIndex: Int,
    val completedStageIndex: Int,
    val totalPoints: Int,
    val survivorIds: List<String>,
    val survivorLoadouts: List<String>,  
    val survivorHealth: Map<String, Double> = mapOf(),  
    val stages: List<ActiveArenaStageData>,
    val hasStarted: Boolean,
    val isCompleted: Boolean,
    val successful: Boolean,
    val bailedOut: Boolean = false,
    val createdAt: Long,
    val lastUpdatedAt: Long
)

@Serializable
data class ActiveArenaStageData(
    val index: Int,
    val survivorCount: Int,
    val survivorPoints: Int,
    val objectivePoints: Int,
    val state: Int  
)
