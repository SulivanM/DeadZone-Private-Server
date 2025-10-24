package core.items

import core.items.model.Item
import data.collection.Inventory

interface InventoryRepository {
    suspend fun getInventory(playerId: String): Result<Inventory>
    suspend fun updateInventory(playerId: String, updatedInventory: List<Item>): Result<Unit>
    suspend fun updateSchematics(playerId: String, updatedSchematics: ByteArray): Result<Unit>
}
