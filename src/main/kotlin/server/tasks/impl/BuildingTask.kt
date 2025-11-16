package server.tasks.impl

import context.ServerContext
import context.requirePlayerContext
import core.model.game.data.copy
import core.model.game.data.level
import core.model.game.data.type
import core.model.game.data.upgrade
import core.model.game.data.repair
import server.broadcast.BroadcastService
import server.core.Connection
import server.messaging.NetworkMessage
import server.tasks.*
import common.LogConfigSocketError
import common.Logger
import kotlin.math.pow
import kotlin.time.Duration

/**
 * Task responsible for handling building creation and upgrades.
 * Executes after the build duration completes, finalizing the building state and granting XP.
 */
class BuildingCreateTask(
    override val taskInputBlock: BuildingCreateParameter.() -> Unit,
    override val stopInputBlock: BuildingCreateStopParameter.() -> Unit
) : ServerTask<BuildingCreateParameter, BuildingCreateStopParameter>() {
    private val taskInput: BuildingCreateParameter by lazy {
        createTaskInput().apply(taskInputBlock)
    }

    override val category = TaskCategory.Building.Create
    override val config = TaskConfig(
        startDelay = taskInput.buildDuration
    )
    override val scheduler: TaskScheduler? = null

    override fun createTaskInput(): BuildingCreateParameter = BuildingCreateParameter()
    override fun createStopInput(): BuildingCreateStopParameter = BuildingCreateStopParameter()

    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        val serverContext = taskInput.serverContext
        if (serverContext != null) {
            val playerContext = serverContext.requirePlayerContext(connection.playerId)
            val compoundService = playerContext.services.compound
            val survivorService = playerContext.services.survivor
            val building = compoundService.getBuilding(taskInput.buildingId)
            if (building != null) {
                val upgradeData = building.upgrade?.data
                val newLevel = (upgradeData?.get("level") as? Int) ?: (building.level + 1)
                val xpEarned = (upgradeData?.get("xp") as? Int) ?: 0

                val updateResult = compoundService.updateBuilding(taskInput.buildingId) { bld ->
                    bld.copy(level = newLevel, upgrade = null)
                }
                if (updateResult.isFailure) {
                    Logger.error(LogConfigSocketError) {
                        "Failed to finalize building upgrade for bldId=${taskInput.buildingId}, playerId=${connection.playerId}: ${updateResult.exceptionOrNull()?.message}"
                    }
                } else if (xpEarned > 0) {
                    // Grant XP to player leader for completing building upgrade
                    val leader = survivorService.getSurvivorLeader()
                    val newXp = leader.xp + xpEarned
                    val newLevel = calculateLevel(newXp)
                    val oldLevel = leader.level
                    val newLevelPts = newLevel - oldLevel

                    val xpUpdateResult = survivorService.updateSurvivor(leader.id) { currentLeader ->
                        currentLeader.copy(xp = newXp, level = newLevel)
                    }
                    if (xpUpdateResult.isFailure) {
                        Logger.error(LogConfigSocketError) {
                            "Failed to grant building XP for playerId=${connection.playerId}: ${xpUpdateResult.exceptionOrNull()?.message}"
                        }
                    } else {
                        Logger.info(LogConfigSocketError) {
                            "Granted $xpEarned XP to player leader for building upgrade (bldId=${taskInput.buildingId})"
                        }

                        // Update player levelPts if player leveled up
                        if (newLevelPts > 0) {
                            try {
                                val playerObjects = serverContext.db.loadPlayerObjects(connection.playerId)
                                if (playerObjects != null) {
                                    val updatedLevelPts = playerObjects.levelPts + newLevelPts.toUInt()
                                    val updatedPlayerObjects = playerObjects.copy(levelPts = updatedLevelPts)
                                    serverContext.db.updatePlayerObjectsJson(connection.playerId, updatedPlayerObjects)

                                    Logger.info(LogConfigSocketError) {
                                        "Player leveled up: ${oldLevel} -> ${newLevel} (+${newLevelPts} levelPts)"
                                    }
                                }
                            } catch (e: Exception) {
                                Logger.error(LogConfigSocketError) {
                                    "Failed to update player levelPts for playerId=${connection.playerId}: ${e.message}"
                                }
                            }

                            // Broadcast level up
                            try {
                                val playerProfile = serverContext.playerAccountRepository.getProfileOfPlayerId(connection.playerId).getOrNull()
                                val playerName = playerProfile?.displayName ?: connection.playerId
                                BroadcastService.broadcastUserLevel(playerName, newLevel)
                            } catch (e: Exception) {
                                Logger.warn("Failed to broadcast user level: ${e.message}")
                            }
                        }
                    }
                }
            }
        }
        connection.sendMessage(NetworkMessage.TASK_COMPLETE, taskInput.buildingId)
        connection.sendMessage(NetworkMessage.BUILDING_COMPLETE, taskInput.buildingId)
    }

    /**
     * Calculates player level based on total XP using quadratic formula.
     * XP required for each level: 100 * (level+1)²
     * This matches the client formula: LEVEL_XP_MULTIPLIER * (level+1)² * BASE_XP_MULTIPLIER = 100 * (level+1)² * 1
     */
    private fun calculateLevel(totalXp: Int): Int {
        var level = 0
        var xpNeeded = 0
        while (true) {
            val nextLevel = level + 1
            val xpForNextLevel = 100 * nextLevel * nextLevel
            if (totalXp >= xpNeeded + xpForNextLevel) {
                xpNeeded += xpForNextLevel
                level++
            } else {
                break
            }
        }
        return level
    }
}

data class BuildingCreateParameter(
    var buildingId: String = "",
    var buildDuration: Duration = Duration.ZERO,
    var serverContext: ServerContext? = null
)

data class BuildingCreateStopParameter(
    var buildingId: String = "",
)

/**
 * Task responsible for handling building repairs.
 * Executes after the repair duration completes, restoring the building to operational state.
 */
class BuildingRepairTask(
    override val taskInputBlock: BuildingRepairParameter.() -> Unit,
    override val stopInputBlock: BuildingRepairStopParameter.() -> Unit
) : ServerTask<BuildingRepairParameter, BuildingRepairStopParameter>() {
    private val taskInput: BuildingRepairParameter by lazy {
        createTaskInput().apply(taskInputBlock)
    }

    override val category = TaskCategory.Building.Repair
    override val config = TaskConfig(
        startDelay = taskInput.repairDuration
    )
    override val scheduler: TaskScheduler? = null

    override fun createTaskInput(): BuildingRepairParameter = BuildingRepairParameter()
    override fun createStopInput(): BuildingRepairStopParameter = BuildingRepairStopParameter()

    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        val serverContext = taskInput.serverContext
        if (serverContext != null) {
            val compoundService = serverContext.requirePlayerContext(connection.playerId).services.compound
            val building = compoundService.getBuilding(taskInput.buildingId)
            if (building != null) {
                val updateResult = compoundService.updateBuilding(taskInput.buildingId) { bld ->
                    bld.copy(repair = null, destroyed = false)
                }
                if (updateResult.isFailure) {
                    Logger.error(LogConfigSocketError) {
                        "Failed to finalize building repair for bldId=${taskInput.buildingId}, playerId=${connection.playerId}: ${updateResult.exceptionOrNull()?.message}"
                    }
                }
            }
        }
        connection.sendMessage(NetworkMessage.TASK_COMPLETE, taskInput.buildingId)
        connection.sendMessage(NetworkMessage.BUILDING_COMPLETE, taskInput.buildingId)
    }
}

data class BuildingRepairParameter(
    var buildingId: String = "",
    var repairDuration: Duration = Duration.ZERO,
    var serverContext: ServerContext? = null
)

data class BuildingRepairStopParameter(
    var buildingId: String = "",
)
