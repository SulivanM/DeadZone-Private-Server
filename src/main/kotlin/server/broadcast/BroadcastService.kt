package server.broadcast

import server.broadcast.BroadcastService.initialize
import server.core.BroadcastServer
import common.Logger

/**
 * A singleton service that provides a simple API for broadcasting messages to all connected clients.
 *
 * This service offers one-line call to broadcast over [BroadcastServer].
 * It must be initialized via [initialize] with an instance of [BroadcastServer] before use.
 *
 * Note that this service does **not** manage the server lifecycle — it should not start or shut down
 * the server. Its sole responsibility is to hold a reference to the broadcast server and delegate
 * broadcast operations.
 */
@Suppress("unused")
object BroadcastService {
    private lateinit var broadcastServer: BroadcastServer
    private var enabled = true

    /**
     * Initialize the broadcast service
     */
    fun initialize(broadcastServer: BroadcastServer) {
        this.broadcastServer = broadcastServer
    }

    /**
     * Broadcasts a message to all connected clients
     */
    suspend fun broadcast(message: BroadcastMessage) {
        if (!enabled) {
            Logger.warn { "Broadcast is not enabled" }
        }
        broadcastServer.broadcast(message)
    }

    /**
     * Broadcasts a raw message string to all connected clients
     */
    suspend fun broadcast(message: String) {
        if (!enabled) {
            Logger.warn { "Broadcast is not enabled" }
        }
        broadcastServer.broadcast(message)
    }

    /**
     * Returns the number of connected clients
     */
    fun getClientCount(): Int = broadcastServer.getClientCount()

    /**
     * Checks if the broadcast service is enabled
     */
    fun isEnabled(): Boolean = enabled

    // Convenience methods for common broadcast types
    suspend fun broadcastPlainText(text: String) {
        broadcast(BroadcastMessage.plainText(text))
    }

    suspend fun broadcastAdmin(text: String) {
        broadcast(BroadcastMessage.admin(text))
    }

    suspend fun broadcastWarning(text: String) {
        broadcast(BroadcastMessage.warning(text))
    }

    suspend fun broadcastShutdown(reason: String = "") {
        broadcast(
            BroadcastMessage(
                BroadcastProtocol.SHUT_DOWN,
                if (reason.isNotEmpty()) listOf(reason) else emptyList()
            )
        )
    }

    suspend fun broadcastItemUnboxed(playerName: String, itemName: String, quality: String = "") {
        val args = if (quality.isNotEmpty()) {
            listOf(playerName, itemName, quality)
        } else {
            listOf(playerName, itemName)
        }
        broadcast(BroadcastMessage(BroadcastProtocol.ITEM_UNBOXED, args))
    }

    suspend fun broadcastItemFound(playerName: String, itemName: String, quality: String = "") {
        val args = if (quality.isNotEmpty()) {
            listOf(playerName, itemName, quality)
        } else {
            listOf(playerName, itemName)
        }
        broadcast(BroadcastMessage(BroadcastProtocol.ITEM_FOUND, args))
    }

    suspend fun broadcastItemCrafted(playerName: String, itemName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.ITEM_CRAFTED, listOf(playerName, itemName)))
    }

    suspend fun broadcastRaidAttack(attackerName: String, defenderName: String, result: String = "") {
        val args = if (result.isNotEmpty()) {
            listOf(attackerName, defenderName, result)
        } else {
            listOf(attackerName, defenderName)
        }
        broadcast(BroadcastMessage(BroadcastProtocol.RAID_ATTACK, args))
    }

    suspend fun broadcastRaidDefend(defenderName: String, attackerName: String, result: String = "") {
        val args = if (result.isNotEmpty()) {
            listOf(defenderName, attackerName, result)
        } else {
            listOf(defenderName, attackerName)
        }
        broadcast(BroadcastMessage(BroadcastProtocol.RAID_DEFEND, args))
    }

    suspend fun broadcastAchievement(playerName: String, achievementName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.ACHIEVEMENT, listOf(playerName, achievementName)))
    }

    suspend fun broadcastUserLevel(playerName: String, level: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.USER_LEVEL, listOf(playerName, level.toString())))
    }

    suspend fun broadcastSurvivorCount(playerName: String, count: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.SURVIVOR_COUNT, listOf(playerName, count.toString())))
    }

    suspend fun broadcastZombieAttackFail(playerName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.ZOMBIE_ATTACK_FAIL, listOf(playerName)))
    }

    suspend fun broadcastAllInjured(playerName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.ALL_INJURED, listOf(playerName)))
    }

    suspend fun broadcastBountyAdd(playerName: String, bountyAmount: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.BOUNTY_ADD, listOf(playerName, bountyAmount.toString())))
    }

    suspend fun broadcastBountyCollected(collectorName: String, targetName: String, bountyAmount: Int) {
        broadcast(
            BroadcastMessage(
                BroadcastProtocol.BOUNTY_COLLECTED,
                listOf(collectorName, targetName, bountyAmount.toString())
            )
        )
    }

    suspend fun broadcastAllianceRaidSuccess(allianceName: String, targetName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.ALLIANCE_RAID_SUCCESS, listOf(allianceName, targetName)))
    }

    suspend fun broadcastAllianceRank(allianceName: String, rank: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.ALLIANCE_RANK, listOf(allianceName, rank.toString())))
    }

    suspend fun broadcastArenaLeaderboard(playerName: String, rank: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.ARENA_LEADERBOARD, listOf(playerName, rank.toString())))
    }

    suspend fun broadcastRaidMissionStarted(playerName: String, missionName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.RAIDMISSION_STARTED, listOf(playerName, missionName)))
    }

    suspend fun broadcastRaidMissionComplete(playerName: String, missionName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.RAIDMISSION_COMPLETE, listOf(playerName, missionName)))
    }

    suspend fun broadcastRaidMissionFailed(playerName: String, missionName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.RAIDMISSION_FAILED, listOf(playerName, missionName)))
    }

    suspend fun broadcastHazSuccess(playerName: String, hazardName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.HAZ_SUCCESS, listOf(playerName, hazardName)))
    }

    suspend fun broadcastHazFail(playerName: String, hazardName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.HAZ_FAIL, listOf(playerName, hazardName)))
    }
}
