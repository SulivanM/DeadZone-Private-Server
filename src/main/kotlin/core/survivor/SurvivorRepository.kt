package dev.deadzone.core.survivor

import dev.deadzone.core.model.game.data.Survivor

interface SurvivorRepository {
    /**
     * Get survivors of [playerId].
     */
    suspend fun getSurvivors(playerId: String): Result<List<Survivor>>

    /**
     * Update survivor field of [playerId] for the [srvId]
     */
    suspend fun updateSurvivor(
        playerId: String,
        srvId: String,
        updatedSurvivor: Survivor
    ): Result<Unit>
}
