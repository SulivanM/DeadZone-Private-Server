package context

import core.compound.CompoundService
import core.items.BatchRecycleJobService
import core.items.InventoryService
import core.metadata.PlayerObjectsMetadataService
import core.survivor.SurvivorService
import data.collection.PlayerAccount
import server.core.Connection

/**
 * A player-scoped data holder. This includes player's socket connection, metadata,
 * and the player's game data, which isn't directly, but found in various [PlayerService].
 *
 * A PlayerContext, including its services, is initialized in the [JoinHandler].
 */
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
