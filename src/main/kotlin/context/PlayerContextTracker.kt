package dev.deadzone.context

import com.mongodb.kotlin.client.coroutine.MongoCollection
import dev.deadzone.core.compound.CompoundRepositoryMongo
import dev.deadzone.core.compound.CompoundService
import dev.deadzone.core.items.InventoryRepositoryMongo
import dev.deadzone.core.items.InventoryService
import dev.deadzone.core.metadata.PlayerObjectsMetadataRepositoryMongo
import dev.deadzone.core.metadata.PlayerObjectsMetadataService
import dev.deadzone.core.survivor.SurvivorRepositoryMongo
import dev.deadzone.core.survivor.SurvivorService
import dev.deadzone.data.collection.Inventory
import dev.deadzone.data.collection.NeighborHistory
import dev.deadzone.data.collection.PlayerObjects
import dev.deadzone.data.db.BigDB
import dev.deadzone.data.db.CollectionName
import dev.deadzone.socket.core.Connection
import io.ktor.util.date.getTimeMillis
import java.util.concurrent.ConcurrentHashMap

/**
 * Tracks each active player context and socket connection.
 */
class PlayerContextTracker {
    val players = ConcurrentHashMap<String, PlayerContext>()

    /**
     * Create context for a player
     */
    suspend fun createContext(
        playerId: String,
        connection: Connection,
        db: BigDB,
        useMongo: Boolean
    ) {
        val playerAccount =
            requireNotNull(db.loadPlayerAccount(playerId)) { "Missing PlayerAccount for playerid=$playerId" }

        val context = PlayerContext(
            playerId = playerId,
            connection = connection,
            onlineSince = getTimeMillis(),
            playerAccount = playerAccount,
            services = initializeServices(playerId, db, useMongo)
        )
        players[playerId] = context
    }

    private suspend fun initializeServices(
        playerId: String,
        db: BigDB,
        useMongo: Boolean
    ): PlayerServices {
        // if (useMongo)

        val plyObj =
            db.getCollection<MongoCollection<PlayerObjects>>(CollectionName.PLAYER_OBJECTS_COLLECTION)
        val neighbor =
            db.getCollection<MongoCollection<NeighborHistory>>(CollectionName.NEIGHBOR_HISTORY_COLLECTION)
        val inv =
            db.getCollection<MongoCollection<Inventory>>(CollectionName.INVENTORY_COLLECTION)

        val account =
            requireNotNull(db.loadPlayerAccount(playerId)) { "Weird, PlayerAccount for playerId=$playerId is null" }
        val playerObjects =
            requireNotNull(db.loadPlayerObjects(playerId)) { "Weird, PlayerObjects for playerId=$playerId is null" }

        val survivor = SurvivorService(
            survivorLeaderId = playerObjects.playerSurvivor!!,
            survivorRepository = SurvivorRepositoryMongo(plyObj)
        )
        val inventory = InventoryService(inventoryRepository = InventoryRepositoryMongo())
        val compound = CompoundService(compoundRepository = CompoundRepositoryMongo(plyObj))
        val playerObjectMetadata = PlayerObjectsMetadataService(
            playerObjectsMetadataRepository = PlayerObjectsMetadataRepositoryMongo(plyObj)
        )

        survivor.init(playerId)
        inventory.init(playerId)
        compound.init(playerId)
        playerObjectMetadata.init(playerId)

        return PlayerServices(
            survivor = survivor,
            compound = compound,
            inventory = inventory,
            playerObjectMetadata = playerObjectMetadata
        )
    }

    fun getContext(playerId: String): PlayerContext? {
        return players[playerId]
    }

    /**
     * Update the context of a player with a lambda function.
     *
     * The [update] method pass the current context and expects to return the updated context.
     */
    fun updateContext(playerId: String, update: (PlayerContext) -> PlayerContext) {
        val context = players.get(playerId) ?: return
        players[playerId] = update(context)
    }

    /**
     * Remove player to free-up memory.
     */
    fun removePlayer(playerId: String) {
        players.remove(playerId)
    }

    fun shutdown() {
        players.values.forEach {
            it.connection.shutdown()
        }
        players.clear()
    }
}
