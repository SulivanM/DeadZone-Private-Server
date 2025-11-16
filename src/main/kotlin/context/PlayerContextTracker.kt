package context

import core.compound.CompoundRepositoryMaria
import core.compound.CompoundService
import core.items.BatchRecycleJobRepositoryMaria
import core.items.BatchRecycleJobService
import core.items.InventoryRepositoryMaria
import core.items.InventoryService
import core.metadata.PlayerObjectsMetadataRepositoryMaria
import core.metadata.PlayerObjectsMetadataService
import core.survivor.SurvivorRepositoryMaria
import core.survivor.SurvivorService
import data.db.BigDB
import data.db.BigDBMariaImpl
import io.ktor.util.date.*
import server.core.Connection
import java.util.concurrent.ConcurrentHashMap

class PlayerContextTracker {
    val players = ConcurrentHashMap<String, PlayerContext>()
    
    suspend fun createContext(playerId: String, connection: Connection, db: BigDB) {
        val playerAccount = requireNotNull(db.loadPlayerAccount(playerId)) { 
            "Missing PlayerAccount for playerid=$playerId" 
        }
        
        val context = PlayerContext(
            playerId = playerId,
            connection = connection,
            onlineSince = getTimeMillis(),
            playerAccount = playerAccount,
            services = initializeServices(playerId, db)
        )
        players[playerId] = context
    }
    
    private suspend fun initializeServices(playerId: String, db: BigDB): PlayerServices {
        // Récupérer la database Exposed depuis BigDB
        val database = (db as BigDBMariaImpl).database
        
        requireNotNull(db.loadPlayerAccount(playerId)) { 
            "Weird, PlayerAccount for playerId=$playerId is null" 
        }
        
        val playerObjects = requireNotNull(db.loadPlayerObjects(playerId)) { 
            "Weird, PlayerObjects for playerId=$playerId is null" 
        }

        val survivor = SurvivorService(
            survivorLeaderId = playerObjects.playerSurvivor!!,
            survivorRepository = SurvivorRepositoryMaria(database)
        )
        
        val inventory = InventoryService(inventoryRepository = InventoryRepositoryMaria(database))
        val compound = CompoundService(compoundRepository = CompoundRepositoryMaria(database))
        val playerObjectMetadata = PlayerObjectsMetadataService(
            playerObjectsMetadataRepository = PlayerObjectsMetadataRepositoryMaria(database)
        )
        val batchRecycleJob = BatchRecycleJobService(
            batchRecycleJobRepository = BatchRecycleJobRepositoryMaria(database)
        )
        
        survivor.init(playerId).onFailure { "Failure during survivor service init: ${it.message}" }
        inventory.init(playerId).onFailure { "Failure during inventory service init: ${it.message}" }
        compound.init(playerId).onFailure { "Failure during compound service init: ${it.message}" }
        playerObjectMetadata.init(playerId).onFailure { "Failure during playerObjectMetadata service init: ${it.message}" }
        batchRecycleJob.init(playerId).onFailure { "Failure during batchRecycleJob service init: ${it.message}" }
        
        return PlayerServices(
            survivor = survivor,
            compound = compound,
            inventory = inventory,
            playerObjectMetadata = playerObjectMetadata,
            batchRecycleJob = batchRecycleJob
        )
    }
    
    fun getContext(playerId: String): PlayerContext? {
        return players[playerId]
    }
    
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
