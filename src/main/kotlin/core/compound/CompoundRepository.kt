package dev.deadzone.core.compound

import dev.deadzone.core.model.game.data.BuildingLike
import dev.deadzone.core.model.game.data.GameResources

interface CompoundRepository {
    // Resource C_U_
    suspend fun getGameResources(playerId: String): Result<GameResources>
    suspend fun updateGameResources(
        playerId: String,
        newResources: GameResources
    ): Result<Unit>

    // Building CRUD
    suspend fun createBuilding(
        playerId: String,
        newBuilding: BuildingLike
    ): Result<Unit>
    suspend fun getBuildings(playerId: String): Result<List<BuildingLike>>
    suspend fun updateBuilding(
        playerId: String,
        bldId: String,
        updatedBuilding: BuildingLike
    ): Result<Unit>
    suspend fun deleteBuilding(playerId: String, bldId: String): Result<Unit>
}
