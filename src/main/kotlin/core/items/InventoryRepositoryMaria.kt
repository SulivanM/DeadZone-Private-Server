package core.items

import core.items.model.Item
import data.collection.Inventory
import data.db.InventoryTable
import kotlinx.serialization.json.Json
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.jetbrains.exposed.sql.update

class InventoryRepositoryMaria(private val database: Database) : InventoryRepository {
    private val json = Json { ignoreUnknownKeys = true }

    override fun getInventory(playerId: String): Result<Inventory> {
        return runCatching {
            transaction(database) {
                InventoryTable.selectAll().where { InventoryTable.playerId eq playerId }.singleOrNull()?.let { row ->
                    val inventory = json.decodeFromString(Inventory.serializer(), row[InventoryTable.dataJson])
                    inventory
                } ?: throw NoSuchElementException("No inventory found with id=$playerId")
            }
        }
    }

    override fun updateInventory(
        playerId: String,
        updatedInventory: List<Item>
    ): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = InventoryTable.selectAll().where { InventoryTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(Inventory.serializer(), row[InventoryTable.dataJson])
                    } ?: throw NoSuchElementException("No inventory found with id=$playerId")
                val updatedData = currentData.copy(inventory = updatedInventory)
                InventoryTable.update({ InventoryTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(Inventory.serializer(), updatedData)
                }
            }
        }
    }

    override fun updateSchematics(
        playerId: String,
        updatedSchematics: ByteArray
    ): Result<Unit> {
        return runCatching {
            transaction(database) {
                val currentData = InventoryTable.selectAll().where { InventoryTable.playerId eq playerId }
                    .singleOrNull()?.let { row ->
                        json.decodeFromString(Inventory.serializer(), row[InventoryTable.dataJson])
                    } ?: throw NoSuchElementException("No player found with id=$playerId")
                val updatedData = currentData.copy(schematics = updatedSchematics)
                InventoryTable.update({ InventoryTable.playerId eq playerId }) {
                    it[dataJson] = json.encodeToString(Inventory.serializer(), updatedData)
                }
            }
        }
    }
}