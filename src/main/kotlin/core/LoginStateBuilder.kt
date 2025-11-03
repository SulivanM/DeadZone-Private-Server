package core

import context.ServerContext
import core.data.PlayerLoginState
import utils.JSON

object LoginStateBuilder {
    suspend fun build(serverContext: ServerContext, pid: String): String {
        val context = serverContext.playerContextTracker.getContext(playerId = pid)!!
        val playerObjects = serverContext.db.loadPlayerObjects(pid)

        return JSON.encode(
            PlayerLoginState(
                settings = emptyMap(),
                news = emptyMap(),
                sales = emptyList(),
                allianceWinnings = emptyMap(),
                recentPVPList = emptyList(),
                invsize = 500,
                upgrades = "",
                allianceId = playerObjects?.allianceId,
                allianceTag = playerObjects?.allianceTag,
                longSession = false,
                leveledUp = false,
                promos = emptyList(),
                promoSale = null,
                dealItem = null,
                leaderResets = 0,
                unequipItemBinds = emptyList(),
                globalStats = emptyMap(),
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
