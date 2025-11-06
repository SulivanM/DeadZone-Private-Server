package core.compound

import core.model.game.data.BuildingLike
import core.model.game.data.GameResources

interface CompoundRepository {
    
    suspend fun getGameResources(playerId: String): Result<GameResources>
    suspend fun updateGameResources(
        playerId: String,
        newResources: GameResources
    ): Result<Unit>

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
    suspend fun updateAllBuildings(
        playerId: String,
        updatedBuildings: List<BuildingLike>
    ): Result<Unit>
    suspend fun deleteBuilding(playerId: String, bldId: String): Result<Unit>
}
