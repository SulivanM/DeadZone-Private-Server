package dev.deadzone.context

import dev.deadzone.core.compound.CompoundService
import dev.deadzone.core.items.InventoryService
import dev.deadzone.core.metadata.PlayerObjectsMetadataService
import dev.deadzone.core.survivor.SurvivorService
import dev.deadzone.data.collection.PlayerAccount
import dev.deadzone.socket.core.Connection

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
    val playerObjectMetadata: PlayerObjectsMetadataService
)
