package core.items

import core.items.model.Item
import data.collection.Inventory
import data.db.PlayerAccounts
import data.db.suspendedTransactionResult
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.update
import common.JSON

class InventoryRepositoryMaria(private val database: Database) : InventoryRepository {
    override suspend fun getInventory(playerId: String): Result<Inventory> {
        return database.suspendedTransactionResult {
            PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    val inventory = JSON.decode(Inventory.serializer(), row[PlayerAccounts.inventoryJson])
                    inventory
                } ?: throw NoSuchElementException("getInventory: No Inventory found with id=$playerId")
        }
    }

    override suspend fun updateInventory(
        playerId: String,
        updatedInventory: List<Item>
    ): Result<Unit> {
        return database.suspendedTransactionResult {
            val currentData = PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    JSON.decode(Inventory.serializer(), row[PlayerAccounts.inventoryJson])
                } ?: throw NoSuchElementException("updateInventory: No Inventory found with id=$playerId")

            val updatedData = currentData.copy(inventory = updatedInventory)

            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[inventoryJson] = JSON.encode(Inventory.serializer(), updatedData)
            }
            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to update inventory in updateInventory for playerId=$playerId")
            }
        }
    }

    override suspend fun updateSchematics(
        playerId: String,
        updatedSchematics: ByteArray
    ): Result<Unit> {
        return database.suspendedTransactionResult {
            val currentData = PlayerAccounts
                .selectAll()
                .where { PlayerAccounts.playerId eq playerId }
                .singleOrNull()
                ?.let { row ->
                    JSON.decode(Inventory.serializer(), row[PlayerAccounts.inventoryJson])
                } ?: throw NoSuchElementException("updateSchematics: No Inventory found with id=$playerId")

            val updatedData = currentData.copy(schematics = updatedSchematics)

            val rowsUpdated = PlayerAccounts.update({ PlayerAccounts.playerId eq playerId }) {
                it[inventoryJson] = JSON.encode(Inventory.serializer(), updatedData)
            }
            if (rowsUpdated == 0) {
                throw IllegalStateException("Failed to update inventory in updateSchematics for playerId=$playerId")
            }
        }
    }
}
