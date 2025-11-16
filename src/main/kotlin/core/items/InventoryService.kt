package core.items

import core.PlayerService
import core.items.model.Item
import common.LogConfigSocketError
import common.Logger

/**
 * Service for managing player inventory and schematics.
 * Provides operations for item management, crafting recipes, and inventory updates.
 */
class InventoryService(
    private val inventoryRepository: InventoryRepository
) : PlayerService {
    private var inventory = listOf<Item>()
    private var schematics = byteArrayOf()
    private lateinit var playerId: String

    fun getInventory(): List<Item> {
        return inventory
    }

    fun getSchematics(): ByteArray {
        return schematics
    }

    suspend fun updateInventory(
        updateAction: suspend (List<Item>) -> List<Item>
    ): Result<Unit> {
        val updatedInventory = updateAction(this.inventory)
        val result = inventoryRepository.updateInventory(playerId, updatedInventory)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on updateInventory: ${it.message}" }
        }
        result.onSuccess {
            inventory = updatedInventory
        }
        return result
    }

    suspend fun updateSchematics(
        updateAction: suspend (ByteArray) -> ByteArray
    ): Result<Unit> {
        val updatedSchematics = updateAction(schematics)
        val result = inventoryRepository.updateSchematics(playerId, updatedSchematics)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on updateSchematics: ${it.message}" }
        }
        result.onSuccess {
            schematics = updatedSchematics
        }
        return result
    }

    override suspend fun init(playerId: String): Result<Unit> {
        return runCatching {
            this.playerId = playerId
            val inventoryObject = inventoryRepository.getInventory(playerId).getOrThrow()
            inventory = inventoryObject.inventory
            schematics = inventoryObject.schematics
        }
    }

    override suspend fun close(playerId: String): Result<Unit> {
        return Result.success(Unit)
    }
}
