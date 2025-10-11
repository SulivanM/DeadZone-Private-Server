package data.db

import data.collection.Inventory
import data.collection.NeighborHistory
import data.collection.PlayerAccount
import data.collection.PlayerObjects

enum class CollectionName {
    PLAYER_ACCOUNT_COLLECTION, PLAYER_OBJECTS_COLLECTION,
    NEIGHBOR_HISTORY_COLLECTION, INVENTORY_COLLECTION,
}

/**
 * Representation of PlayerIO BigDB
 */
interface BigDB {
    // each method load the corresponding collection
    suspend fun loadPlayerAccount(playerId: String): PlayerAccount?
    suspend fun loadPlayerObjects(playerId: String): PlayerObjects?
    suspend fun loadNeighborHistory(playerId: String): NeighborHistory?
    suspend fun loadInventory(playerId: String): Inventory?

    /**
     * A cheat solution to update [PlayerObjects] without relying on repository CRUD methods.
     *
     * This updates the entire JSON with the given [updatedPlayerObjects].
     */
    suspend fun updatePlayerObjectsJson(playerId: String, updatedPlayerObjects: PlayerObjects)

    /**
     * Get a particular collection without type safety.
     *
     * Typically used when repository independent of DB implementation needs
     * to its implementor collection.
     */
    suspend fun <T> getCollection(name: CollectionName): T

    /**
     * Create a user with the provided username and password.
     *
     * This method is defined in BigDB because it require access to all 5 collections,
     * in which a focused repository do not own.
     *
     * @return playerId (UUID) of the newly created user.
     */
    suspend fun createUser(username: String, password: String): String

    suspend fun shutdown()
}
