package core.survivor

import core.model.game.data.Survivor

interface SurvivorRepository {
    suspend fun getSurvivors(playerId: String): Result<List<Survivor>>
    suspend fun addSurvivor(playerId: String, survivor: Survivor): Result<Unit>
    suspend fun updateSurvivor(playerId: String, srvId: String, updatedSurvivor: Survivor): Result<Unit>
    suspend fun updateSurvivors(playerId: String, survivors: List<Survivor>): Result<Unit>
}
