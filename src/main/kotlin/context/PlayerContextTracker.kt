package context

import dev.deadzone.core.compound.CompoundRepositoryMaria
import dev.deadzone.core.compound.CompoundService
import dev.deadzone.core.items.InventoryRepositoryMaria
import dev.deadzone.core.items.InventoryService
import core.metadata.PlayerObjectsMetadataRepositoryMaria
import dev.deadzone.core.metadata.PlayerObjectsMetadataService
import core.survivor.SurvivorRepositoryMaria
import core.survivor.SurvivorService
import dev.deadzone.context.PlayerContext
import dev.deadzone.context.PlayerServices
import dev.deadzone.data.db.BigDB
import dev.deadzone.data.db.BigDBMariaImpl
import socket.core.Connection
import io.ktor.util.date.getTimeMillis
import kotlinx.serialization.json.Json
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
        
        val json = Json { ignoreUnknownKeys = true }
        
        val survivor = SurvivorService(
            survivorLeaderId = playerObjects.playerSurvivor!!,
            survivorRepository = SurvivorRepositoryMaria(database)
        )
        
        val inventory = InventoryService(inventoryRepository = InventoryRepositoryMaria())
        val compound = CompoundService(compoundRepository = CompoundRepositoryMaria(database, json))
        val playerObjectMetadata = PlayerObjectsMetadataService(
            playerObjectsMetadataRepository = PlayerObjectsMetadataRepositoryMaria(database, json)
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
