package dev.deadzone.core

import dev.deadzone.context.GlobalContext
import dev.deadzone.context.ServerContext
import dev.deadzone.core.data.PlayerLoginState

/**
 * Per-player dynamic updates.
 *
 * Assumption:
 *   Some fields come from PlayerObjects and represent values that change over time.
 *   When a player logs out, their data is stored in the database, but certain values
 *   (e.g., resources) can change while they’re offline due to natural depletion or
 *   external events such as PvP attacks.
 *
 *   Therefore, when the player logs in, we must recalculate these values to reflect
 *   the time elapsed since their last session. The updated values should then be
 *   written back to the database before proceeding, since API 85 (the load request)
 *   will immediately send this data to the client.
 */
object LoginStateBuilder {
    /**
     * Build login state for the given [pid], returning the raw JSON string.
     */
    fun build(serverContext: ServerContext, pid: String): String {
        // must not be null, just initialized in handle
        val context = serverContext.playerContextTracker.getContext(playerId = pid)!!

        // TODO: create service and repository methods
        return GlobalContext.json.encodeToString(
            PlayerLoginState(
                // global game services
                settings = emptyMap(),
                news = emptyMap(),
                sales = emptyList(),
                allianceWinnings = emptyMap(),
                recentPVPList = emptyList(),

                // per-player update
                invsize = 500, // the default inventory size
                upgrades = "",

                // per-player data
                allianceId = null,
                allianceTag = null,

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
                bountyCap = null,
                bountyCapTimestamp = null,
                research = null
            )
        )
    }
}
