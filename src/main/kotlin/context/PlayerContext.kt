package context

import core.compound.CompoundService
import core.items.BatchRecycleJobService
import core.items.InventoryService
import core.metadata.PlayerObjectsMetadataService
import core.survivor.SurvivorService
import data.collection.PlayerAccount
import server.core.Connection

data class PlayerContext(
    val playerId: String,
    val connection: Connection,
    val onlineSince: Long,
    val playerAccount: PlayerAccount,
    val services: PlayerServices
)

data class PlayerServices(
    val survivor: SurvivorService,
    val compound: CompoundService,
    val inventory: InventoryService,
    val playerObjectMetadata: PlayerObjectsMetadataService,
    val batchRecycleJob: BatchRecycleJobService
)
