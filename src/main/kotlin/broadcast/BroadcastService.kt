package broadcast

import utils.Logger

/**
 * Service for managing broadcast messages to all connected clients
 * This is a singleton that provides a simple API for broadcasting game events
 */
object BroadcastService {
    private var server: BroadcastServer? = null
    private var policyServer: PolicyFileServer? = null
    private var enabled = false

    /**
     * Initializes the broadcast service with the given configuration
     */
    fun initialize(host: String = "0.0.0.0", ports: List<Int> = listOf(2121, 2122, 2123), enabled: Boolean = true, enablePolicyServer: Boolean = true) {
        if (server != null) {
            Logger.warn("BroadcastService already initialized")
            return
        }

        this.enabled = enabled
        if (!enabled) {
            Logger.info("Broadcast service is disabled")
            return
        }

        // Start policy file server (required for Flash)
        if (enablePolicyServer) {
            policyServer = PolicyFileServer(host, 843, ports)
            policyServer?.start()
        }

        // Start broadcast server
        server = BroadcastServer(host, ports)
        server?.start()
    }

    /**
     * Shuts down the broadcast service
     */
    fun shutdown() {
        server?.stop()
        server = null
        policyServer?.stop()
        policyServer = null
        enabled = false
    }

    /**
     * Broadcasts a message to all connected clients
     */
    fun broadcast(message: BroadcastMessage) {
        if (!enabled || server == null) return
        server?.broadcast(message)
    }

    /**
     * Broadcasts a raw message string to all connected clients
     */
    fun broadcast(message: String) {
        if (!enabled || server == null) return
        server?.broadcast(message)
    }

    /**
     * Returns the number of connected clients
     */
    fun getClientCount(): Int = server?.getClientCount() ?: 0

    /**
     * Checks if the broadcast service is enabled
     */
    fun isEnabled(): Boolean = enabled

    // Convenience methods for common broadcast types

    fun broadcastPlainText(text: String) {
        broadcast(BroadcastMessage.plainText(text))
    }

    fun broadcastAdmin(text: String) {
        broadcast(BroadcastMessage.admin(text))
    }

    fun broadcastWarning(text: String) {
        broadcast(BroadcastMessage.warning(text))
    }

    fun broadcastShutdown(reason: String = "") {
        broadcast(BroadcastMessage(BroadcastProtocol.SHUT_DOWN, if (reason.isNotEmpty()) listOf(reason) else emptyList()))
    }

    fun broadcastItemUnboxed(playerName: String, itemName: String, quality: String = "") {
        val args = if (quality.isNotEmpty()) {
            listOf(playerName, itemName, quality)
        } else {
            listOf(playerName, itemName)
        }
        broadcast(BroadcastMessage(BroadcastProtocol.ITEM_UNBOXED, args))
    }

    fun broadcastItemFound(playerName: String, itemName: String, quality: String = "") {
        val args = if (quality.isNotEmpty()) {
            listOf(playerName, itemName, quality)
        } else {
            listOf(playerName, itemName)
        }
        broadcast(BroadcastMessage(BroadcastProtocol.ITEM_FOUND, args))
    }

    fun broadcastItemCrafted(playerName: String, itemName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.ITEM_CRAFTED, listOf(playerName, itemName)))
    }

    fun broadcastRaidAttack(attackerName: String, defenderName: String, result: String = "") {
        val args = if (result.isNotEmpty()) {
            listOf(attackerName, defenderName, result)
        } else {
            listOf(attackerName, defenderName)
        }
        broadcast(BroadcastMessage(BroadcastProtocol.RAID_ATTACK, args))
    }

    fun broadcastRaidDefend(defenderName: String, attackerName: String, result: String = "") {
        val args = if (result.isNotEmpty()) {
            listOf(defenderName, attackerName, result)
        } else {
            listOf(defenderName, attackerName)
        }
        broadcast(BroadcastMessage(BroadcastProtocol.RAID_DEFEND, args))
    }

    fun broadcastAchievement(playerName: String, achievementName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.ACHIEVEMENT, listOf(playerName, achievementName)))
    }

    fun broadcastUserLevel(playerName: String, level: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.USER_LEVEL, listOf(playerName, level.toString())))
    }

    fun broadcastSurvivorCount(playerName: String, count: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.SURVIVOR_COUNT, listOf(playerName, count.toString())))
    }

    fun broadcastZombieAttackFail(playerName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.ZOMBIE_ATTACK_FAIL, listOf(playerName)))
    }

    fun broadcastAllInjured(playerName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.ALL_INJURED, listOf(playerName)))
    }

    fun broadcastBountyAdd(playerName: String, bountyAmount: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.BOUNTY_ADD, listOf(playerName, bountyAmount.toString())))
    }

    fun broadcastBountyCollected(collectorName: String, targetName: String, bountyAmount: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.BOUNTY_COLLECTED, listOf(collectorName, targetName, bountyAmount.toString())))
    }

    fun broadcastAllianceRaidSuccess(allianceName: String, targetName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.ALLIANCE_RAID_SUCCESS, listOf(allianceName, targetName)))
    }

    fun broadcastAllianceRank(allianceName: String, rank: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.ALLIANCE_RANK, listOf(allianceName, rank.toString())))
    }

    fun broadcastArenaLeaderboard(playerName: String, rank: Int) {
        broadcast(BroadcastMessage(BroadcastProtocol.ARENA_LEADERBOARD, listOf(playerName, rank.toString())))
    }

    fun broadcastRaidMissionStarted(playerName: String, missionName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.RAIDMISSION_STARTED, listOf(playerName, missionName)))
    }

    fun broadcastRaidMissionComplete(playerName: String, missionName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.RAIDMISSION_COMPLETE, listOf(playerName, missionName)))
    }

    fun broadcastRaidMissionFailed(playerName: String, missionName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.RAIDMISSION_FAILED, listOf(playerName, missionName)))
    }

    fun broadcastHazSuccess(playerName: String, hazardName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.HAZ_SUCCESS, listOf(playerName, hazardName)))
    }

    fun broadcastHazFail(playerName: String, hazardName: String) {
        broadcast(BroadcastMessage(BroadcastProtocol.HAZ_FAIL, listOf(playerName, hazardName)))
    }
}
