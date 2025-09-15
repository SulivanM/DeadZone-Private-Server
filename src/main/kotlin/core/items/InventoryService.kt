package dev.deadzone.core.items

import dev.deadzone.core.PlayerService

class InventoryService(
    private val inventoryRepository: InventoryRepository
) : PlayerService {
    override suspend fun init(playerId: String): Result<Unit> {
        return Result.success(Unit)
    }

    override suspend fun close(playerId: String): Result<Unit> {
        return Result.success(Unit)
    }
}
