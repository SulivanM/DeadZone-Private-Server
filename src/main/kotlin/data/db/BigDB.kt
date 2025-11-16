package data.db

import data.collection.*

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
     * Update Inventory JSON for a player
     */
    suspend fun updateInventoryJson(playerId: String, updatedInventory: Inventory)

    /**
     * Update NeighborHistory JSON for a player
     */
    suspend fun updateNeighborHistoryJson(playerId: String, updatedNeighborHistory: NeighborHistory)

    /**
     * Create a new object in BigDB or return existing if loadExisting is true
     *
     * @param table The table name (PlayerObjects, Inventory, NeighborHistory)
     * @param key The object key (typically playerId)
     * @param properties Map of properties to set
     * @param loadExisting If true and object exists, return existing object instead of error
     * @return The created or existing object version
     */
    suspend fun createObject(table: String, key: String, properties: Map<String, Any>, loadExisting: Boolean): String?

    /**
     * Save changes to an existing object with optional optimistic locking
     *
     * @param table The table name
     * @param key The object key
     * @param onlyIfVersion Only save if current version matches (optimistic locking)
     * @param changes Map of property changes to apply
     * @param createIfMissing Create the object if it doesn't exist
     * @return The new version string after save
     */
    suspend fun saveObjectChanges(
        table: String,
        key: String,
        onlyIfVersion: String?,
        changes: Map<String, Any>,
        createIfMissing: Boolean
    ): String?

    /**
     * Delete objects by their keys
     *
     * @param table The table name
     * @param keys List of keys to delete
     */
    suspend fun deleteObjects(table: String, keys: List<String>)

    /**
     * Get a particular collection without type safety.
     *
     * Typically used when repository independent of DB implementation needs
     * to its implementor collection.
     */
    fun <T> getCollection(name: CollectionName): T

    /**
     * Create a user with the provided username and password.
     *
     * This method is defined in BigDB because it require access to all 5 collections,
     * in which a focused repository do not own.
     *
     * @param username The username for the account
     * @param password The password for the account
     * @param email The email address (optional)
     * @param countryCode The country code (optional)
     * @return playerId (UUID) of the newly created user.
     */
    suspend fun createUser(username: String, password: String, email: String? = null, countryCode: String? = null): String

    // ==================== PayVault Operations ====================

    /**
     * Load PayVault data for a player
     */
    suspend fun loadPayVault(playerId: String): PayVaultData?

    /**
     * Update PayVault data
     */
    suspend fun updatePayVault(playerId: String, payVault: PayVaultData)

    /**
     * Credit coins to player's vault
     */
    suspend fun creditCoins(playerId: String, amount: Long, reason: String): PayVaultData

    /**
     * Debit coins from player's vault
     */
    suspend fun debitCoins(playerId: String, amount: Long, reason: String): PayVaultData

    /**
     * Add items to player's vault
     */
    suspend fun giveItems(playerId: String, items: List<PayVaultItemData>): PayVaultData

    /**
     * Consume items from player's vault
     */
    suspend fun consumeItems(playerId: String, itemIds: List<String>): PayVaultData

    // ==================== Alliance Operations ====================

    /**
     * Create a new alliance
     */
    suspend fun createAlliance(
        allianceId: String,
        name: String,
        tag: String,
        bannerBytes: String,
        thumbImage: String,
        creatorPlayerId: String
    ): Boolean

    /**
     * Check if alliance name exists
     */
    suspend fun allianceNameExists(name: String): Boolean

    /**
     * Check if alliance tag exists
     */
    suspend fun allianceTagExists(tag: String): Boolean

    /**
     * Load alliance data by ID
     */
    suspend fun loadAlliance(allianceId: String): core.model.game.data.alliance.AllianceData?

    /**
     * Get all members of an alliance
     */
    suspend fun getAllianceMembers(allianceId: String): List<core.model.game.data.alliance.AllianceMember>

    /**
     * Get all messages from an alliance
     */
    suspend fun getAllianceMessages(allianceId: String): List<core.model.game.data.alliance.AllianceMessage>

    suspend fun shutdown()
}
