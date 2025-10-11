package core.items

import core.items.model.Item
import data.collection.Inventory

interface InventoryRepository {
    fun getInventory(playerId: String): Result<Inventory>
    fun updateInventory(playerId: String, updatedInventory: List<Item>): Result<Unit>
    fun updateSchematics(playerId: String, updatedSchematics: ByteArray): Result<Unit>
}
