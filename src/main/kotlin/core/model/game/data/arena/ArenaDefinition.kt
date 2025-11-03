package core.model.game.data.arena

import kotlinx.serialization.Serializable

@Serializable
data class ArenaDefinition(
    val id: String,
    val levelMin: Int,
    val survivorMin: Int,
    val survivorMax: Int,
    val pointsPerSurvivor: Int,
    val stages: List<ArenaStageDefinition>,
    val rewards: List<ArenaRewardTier>
)

@Serializable
data class ArenaStageDefinition(
    val id: String,
    val index: Int,
    val time: Int,  
    val enemyLevel: Int,  
    val maps: List<String>,
    val triggerPoints: Int,  
    val elites: List<String> = emptyList()
)

@Serializable
data class ArenaRewardTier(
    val score: Int,
    val itemType: String,
    val quantity: Int
)
