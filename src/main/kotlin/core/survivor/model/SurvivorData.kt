package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class SurvivorData(
    val id: String,
    val startXP: Int,
    val startLevel: Int,
    val endXP: Int,
    val endLevel: Int
) {
    companion object {
        fun dummy(id: String): SurvivorData {
            return SurvivorData(
                id = id,
                startXP = 0,
                startLevel = 2,
                endXP = 1000,
                endLevel = 4,
            )
        }
    }
}
