package dev.deadzone.core.data

import com.mongodb.client.model.Filters
import com.mongodb.client.model.Indexes
import com.mongodb.client.model.Updates
import com.mongodb.kotlin.client.coroutine.MongoDatabase
import com.toxicbakery.bcrypt.Bcrypt
import dev.deadzone.core.auth.model.ServerMetadata
import dev.deadzone.core.auth.model.UserProfile
import dev.deadzone.data.collection.Inventory
import dev.deadzone.data.collection.NeighborHistory
import dev.deadzone.data.collection.PlayerAccount
import dev.deadzone.data.collection.PlayerObjects
import dev.deadzone.data.db.BigDB
import dev.deadzone.data.db.CollectionName
import dev.deadzone.utils.Logger
import dev.deadzone.utils.UUID
import io.ktor.util.date.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.launch
import kotlin.io.encoding.Base64

class BigDBMongoImpl(db: MongoDatabase, private val adminEnabled: Boolean) : BigDB {
    private val accCollection = db.getCollection<PlayerAccount>("playeraccount")
    private val objCollection = db.getCollection<PlayerObjects>("playerobjects")
    private val neighborCollection = db.getCollection<NeighborHistory>("neighborhistory")
    private val inventoryCollection = db.getCollection<Inventory>("inventory")

    init {
        Logger.info { "Initializing MongoDB..." }
        CoroutineScope(Dispatchers.IO).launch {
            setupCollections()
        }
        // deleteAdminAccount()
    }

    private suspend fun setupCollections() {
        try {
            val count = accCollection.estimatedDocumentCount()
            Logger.info { "MongoDB: User collection ready, contains $count users." }

            if (adminEnabled) {
                val adminDoc = accCollection.find(Filters.eq("playerId", AdminData.PLAYER_ID)).firstOrNull()
                if (adminDoc == null) {
                    val start = getTimeMillis()
                    val doc = PlayerAccount.admin()
                    val obj = PlayerObjects.admin()
                    val neighbor = NeighborHistory.empty(AdminData.PLAYER_ID)
                    val inv = Inventory.admin()

                    accCollection.insertOne(doc)
                    objCollection.insertOne(obj)
                    neighborCollection.insertOne(neighbor)
                    inventoryCollection.insertOne(inv)

                    Logger.info { "MongoDB: Admin account inserted in ${getTimeMillis() - start}ms" }
                } else {
                    Logger.info { "MongoDB: Admin account already exists." }
                }
            }

            setupIndexes()
        } catch (e: Exception) {
            Logger.error { "MongoDB: Failed during setupUserDocument: $e" }
        }
    }

    suspend fun setupIndexes() {
        accCollection.createIndex(Indexes.text("profile.displayName"))
    }

    override suspend fun loadPlayerAccount(playerId: String): PlayerAccount? {
        return accCollection.find(Filters.eq("playerId", playerId)).firstOrNull()
    }

    override suspend fun loadPlayerObjects(playerId: String): PlayerObjects? {
        return objCollection.find(Filters.eq("playerId", playerId)).firstOrNull()
    }

    override suspend fun loadNeighborHistory(playerId: String): NeighborHistory? {
        return neighborCollection.find(Filters.eq("playerId", playerId)).firstOrNull()
    }

    override suspend fun loadInventory(playerId: String): Inventory? {
        return inventoryCollection.find(Filters.eq("playerId", playerId)).firstOrNull()
    }

    override suspend fun <T> updatePlayerObjectsField(
        playerId: String, path: String, value: T
    ) {
        val filter = Filters.eq("playerId", playerId)
        val update = Updates.set(path, value)
        objCollection.updateOne(filter, update)
    }

    @Suppress("UNCHECKED_CAST")
    override suspend fun <T> getCollection(name: CollectionName): T {
        return when (name) {
            CollectionName.PLAYER_ACCOUNT_COLLECTION -> accCollection
            CollectionName.PLAYER_OBJECTS_COLLECTION -> objCollection
            CollectionName.NEIGHBOR_HISTORY_COLLECTION -> neighborCollection
            CollectionName.INVENTORY_COLLECTION -> inventoryCollection
        } as T
    }

    override suspend fun createUser(username: String, password: String): String {
        val pid = UUID.new()
        val profile = UserProfile.default(username = username, pid = pid)
        val playerSrvId = UUID.new()

        val doc = PlayerAccount(
            playerId = pid,
            hashedPassword = hashPw(password),
            profile = profile,
            serverMetadata = ServerMetadata()
        )

        val obj = PlayerObjects.newgame(pid, username, playerSrvId)
        val neighbor = NeighborHistory.empty(pid)
        val inv = Inventory.newgame(pid)

        accCollection.insertOne(doc)
        objCollection.insertOne(obj)
        neighborCollection.insertOne(neighbor)
        inventoryCollection.insertOne(inv)

        return pid
    }

    private fun hashPw(password: String): String {
        return Base64.encode(Bcrypt.hash(password, 10))
    }

    /**
     * Reset an entire UserDocument collection.
     */
    suspend fun resetUserCollection() {
        accCollection.drop()
    }

    suspend fun deleteAdminAccount() {
        accCollection.findOneAndDelete(Filters.eq("playerId", AdminData.PLAYER_ID))
        objCollection.findOneAndDelete(Filters.eq("playerId", AdminData.PLAYER_ID))
        neighborCollection.findOneAndDelete(Filters.eq("playerId", AdminData.PLAYER_ID))
        inventoryCollection.findOneAndDelete(Filters.eq("playerId", AdminData.PLAYER_ID))
    }

    override suspend fun shutdown() {
        // nothing
    }
}

/**
 * Executes the given [block] that returns a value of type [T] or null.
 *
 * - If [block] returns null, this will return a failed [Result] containing a [NoSuchElementException]
 *   with the provided [nullMessage].
 * - If [block] throws any exception, it will be caught and wrapped in a failed [Result].
 * - Otherwise, the returned non-null value is wrapped in a successful [Result].
 *
 * You need to throw exception explicitly if there are multiple exception messages.
 */
inline fun <T> runMongoCatching(
    nullMessage: String = "Document not found",
    block: () -> T?
): Result<T> {
    return try {
        val value = block()
        if (value == null) {
            Result.failure(NoSuchElementException(nullMessage))
        } else {
            Result.success(value)
        }
    } catch (e: Exception) {
        Result.failure(e)
    }
}

/**
 * Executes the given [block] that returns a [Boolean] indicating success.
 *
 * - If [block] returns false, this will return a failed [Result] containing a [NoSuchElementException]
 *   with the provided [failMessage].
 * - If [block] throws any exception, it will be caught and wrapped in a failed [Result].
 * - If [block] returns true, a successful [Result] with [Unit] is returned.
 *
 * You need to throw exception explicitly if there are multiple exception messages.
 */
inline fun runMongoCatchingUnit(
    failMessage: String = "Document not found",
    block: () -> Boolean
): Result<Unit> {
    return try {
        if (block()) Result.success(Unit)
        else Result.failure(NoSuchElementException(failMessage))
    } catch (e: Exception) {
        Result.failure(e)
    }
}
