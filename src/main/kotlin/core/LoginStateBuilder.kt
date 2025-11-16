package core

import context.PlayerContext
import context.ServerContext
import core.data.GameDefinition
import core.data.PlayerLoginState
import core.model.game.data.level
import core.model.game.data.type
import common.JSON
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi

/**
 * Per-player dynamic updates.
 *
 * Assumption:
 *   Some fields come from PlayerObjects and represent values that change over time.
 *   When a player logs out, their data is stored in the database, but certain values
 *   (e.g., resources) can change while they're offline due to natural depletion or
 *   external events such as PvP attacks.
 *
 *   Therefore, when the player logs in, we must recalculate these values to reflect
 *   the time elapsed since their last session. The updated values should then be
 *   written back to the database before proceeding, since API 85 (the load request)
 *   will immediately send this data to the client.
 */
@OptIn(ExperimentalEncodingApi::class)
object LoginStateBuilder {
    /**
     * Build login state for the given [pid], returning the raw JSON string.
     */
    suspend fun build(serverContext: ServerContext, pid: String): String {
        // must not be null, just initialized in handle
        val context = serverContext.playerContextTracker.getContext(playerId = pid)!!
        val playerObjects = serverContext.db.loadPlayerObjects(pid)

        // TODO: create service and repository methods
        return JSON.encode(
            PlayerLoginState(
                // global game services
                settings = emptyMap(),
                news = emptyMap(),
                sales = emptyList(),
                allianceWinnings = emptyMap(),
                recentPVPList = emptyList(),

                // per-player update
                invsize = calculateInventorySize(context),
                upgrades = playerObjects?.upgrades?.let { Base64.encode(it) } ?: "",

                // per-player data
                allianceId = playerObjects?.allianceId,
                allianceTag = playerObjects?.allianceTag,

                // if true will prompt captcha
                longSession = false,

                // per-player update
                leveledUp = false,

                // global server update
                promos = emptyList(),
                promoSale = null,
                dealItem = null,

                // per-player update
                leaderResets = 0,
                unequipItemBinds = emptyList(),

                // unsure
                globalStats = emptyMap(),

                // per-player update
                resources = context.services.compound.getResources(),
                survivors = context.services.survivor.getAllSurvivors(),
                tasks = null,
                missions = null,
                bountyCap = loadBountyCap(serverContext, pid),
                bountyCapTimestamp = loadBountyCapTimestamp(serverContext, pid),
                research = null,
                dzbounty = loadOrGenerateBounty(serverContext, pid),
                nextDZBountyIssue = loadNextDZBountyIssue(serverContext, pid)
            )
        )
    }

    /**
     * Load or generate a bounty for the player.
     * If the player doesn't have a bounty and it's time to issue one, generate a new one.
     */
    private suspend fun loadOrGenerateBounty(serverContext: ServerContext, playerId: String): core.model.game.data.bounty.InfectedBounty? {
        val playerObjects = serverContext.db.loadPlayerObjects(playerId) ?: return null

        // If player already has a bounty, return it
        if (playerObjects.dzBounty != null) {
            return playerObjects.dzBounty
        }

        // Check if it's time to issue a new bounty
        val currentTime = io.ktor.util.date.getTimeMillis()
        if (currentTime >= playerObjects.nextDZBountyIssue) {
            // Generate a new bounty
            val newBounty = core.bounty.BountyGenerationService.generateInfectedBounty(playerId)
            val nextIssueTime = core.bounty.BountyGenerationService.calculateNextIssueTime()

            // Update player objects with new bounty
            val updatedPlayerObjects = playerObjects.copy(
                dzBounty = newBounty,
                nextDZBountyIssue = nextIssueTime
            )
            serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

            return newBounty
        }

        return null
    }

    /**
     * Load the next bounty issue time for the player.
     */
    private suspend fun loadNextDZBountyIssue(serverContext: ServerContext, playerId: String): Long? {
        val playerObjects = serverContext.db.loadPlayerObjects(playerId) ?: return null
        return playerObjects.nextDZBountyIssue
    }

    /**
     * Load the bounty cap for the player.
     */
    private suspend fun loadBountyCap(serverContext: ServerContext, playerId: String): Int? {
        val playerObjects = serverContext.db.loadPlayerObjects(playerId) ?: return null
        return playerObjects.bountyCap
    }

    /**
     * Load the bounty cap timestamp for the player.
     */
    private suspend fun loadBountyCapTimestamp(serverContext: ServerContext, playerId: String): Long? {
        val playerObjects = serverContext.db.loadPlayerObjects(playerId) ?: return null
        return playerObjects.bountyCapTimestamp
    }

    /**
     * Calculate inventory size based on player's buildings and level.
     * Base size is 500, can be increased by storage buildings.
     */
    private fun calculateInventorySize(context: PlayerContext): Int {
        val baseSize = 500
        val buildings = context.services.compound.getBuildings()

        // Look for storage buildings that increase inventory capacity
        var additionalCapacity = 0
        for (building in buildings) {
            val buildingDef = GameDefinition.findBuilding(building.type) ?: continue
            // Check if building has "store" type (like warehouse)
            if (buildingDef.store != null) {
                val levelDef = buildingDef.getLevel(building.level)
                val capacity = levelDef?.capacity ?: 0
                additionalCapacity += capacity
            }
        }

        return baseSize + additionalCapacity
    }
}
