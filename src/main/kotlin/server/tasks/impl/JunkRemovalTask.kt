package server.tasks.impl

import context.ServerContext
import core.compound.CompoundService
import core.survivor.SurvivorService
import server.broadcast.BroadcastService
import server.core.Connection
import server.messaging.NetworkMessage
import server.tasks.*
import common.LogConfigSocketError
import common.Logger
import core.survivor.XpLevelService
import kotlin.time.Duration

class JunkRemovalTask(
    private val compoundService: CompoundService,
    private val survivorService: SurvivorService,
    private val serverContext: ServerContext,
    override val taskInputBlock: JunkRemovalParameter.() -> Unit,
    override val stopInputBlock: JunkRemovalStopParameter.() -> Unit
) : ServerTask<JunkRemovalParameter, JunkRemovalStopParameter>() {
    private val taskInput: JunkRemovalParameter by lazy {
        createTaskInput().apply(taskInputBlock)
    }

    override val category = TaskCategory.Task.JunkRemoval
    override val config = TaskConfig(
        startDelay = taskInput.removalDuration
    )
    override val scheduler: TaskScheduler? = null

    override fun createTaskInput(): JunkRemovalParameter = JunkRemovalParameter()
    override fun createStopInput(): JunkRemovalStopParameter = JunkRemovalStopParameter()

    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        // Delete the junk building
        compoundService.deleteBuilding(taskInput.buildingId)

        // Grant XP to player leader using centralized service
        if (taskInput.xpReward > 0) {
            try {
                val leader = survivorService.getSurvivorLeader()
                val playerObjects = serverContext.db.loadPlayerObjects(connection.playerId)

                if (playerObjects != null) {
                    // Use centralized XP service for consistent level calculation and rested XP bonus
                    val (updatedLeader, updatedPlayerObjects) = XpLevelService.addXpToLeader(
                        survivor = leader,
                        playerObjects = playerObjects,
                        earnedXp = taskInput.xpReward
                    )

                    val oldLevel = leader.level
                    val newLevel = updatedLeader.level
                    val newLevelPts = (newLevel - oldLevel).coerceAtLeast(0)

                    // Update survivor in database
                    survivorService.updateSurvivor(leader.id) { _ ->
                        updatedLeader
                    }

                    // Update PlayerObjects with new levelPts and consumed restXP
                    serverContext.db.updatePlayerObjectsJson(connection.playerId, updatedPlayerObjects)

                    Logger.info(LogConfigSocketError) {
                        "Granted ${taskInput.xpReward} XP to player leader for junk removal (taskId=${taskInput.taskId}). " +
                        "Level: $oldLevel->$newLevel, XP: ${leader.xp}->${updatedLeader.xp}"
                    }

                    // Broadcast level up if player leveled up
                    if (newLevelPts > 0) {
                        val playerProfile = serverContext.playerAccountRepository.getProfileOfPlayerId(connection.playerId).getOrNull()
                        val playerName = playerProfile?.displayName ?: connection.playerId
                        BroadcastService.broadcastUserLevel(playerName, newLevel)
                    }
                } else {
                    Logger.error(LogConfigSocketError) {
                        "Failed to load PlayerObjects for junk removal XP grant playerId=${connection.playerId}"
                    }
                }
            } catch (e: Exception) {
                Logger.error(LogConfigSocketError) {
                    "Failed to grant XP for junk removal playerId=${connection.playerId}: ${e.message}"
                }
            }
        }

        connection.sendMessage(NetworkMessage.TASK_COMPLETE, taskInput.taskId)
    }

    @InternalTaskAPI
    override suspend fun onTaskComplete(connection: Connection) {
        server.handler.save.compound.task.TaskSaveHandler.cleanupJunkRemovalTask(taskInput.taskId)
    }

    @InternalTaskAPI
    override suspend fun onForceComplete(connection: Connection) {
        // Delete the junk building
        compoundService.deleteBuilding(taskInput.buildingId)

        // Grant XP to player leader using centralized service (same as normal completion)
        if (taskInput.xpReward > 0) {
            try {
                val leader = survivorService.getSurvivorLeader()
                val playerObjects = serverContext.db.loadPlayerObjects(connection.playerId)

                if (playerObjects != null) {
                    // Use centralized XP service for consistent level calculation and rested XP bonus
                    val (updatedLeader, updatedPlayerObjects) = XpLevelService.addXpToLeader(
                        survivor = leader,
                        playerObjects = playerObjects,
                        earnedXp = taskInput.xpReward
                    )

                    val oldLevel = leader.level
                    val newLevel = updatedLeader.level
                    val newLevelPts = (newLevel - oldLevel).coerceAtLeast(0)

                    // Update survivor in database
                    survivorService.updateSurvivor(leader.id) { _ ->
                        updatedLeader
                    }

                    // Update PlayerObjects with new levelPts and consumed restXP
                    serverContext.db.updatePlayerObjectsJson(connection.playerId, updatedPlayerObjects)

                    Logger.info(LogConfigSocketError) {
                        "Granted ${taskInput.xpReward} XP to player leader for instant junk removal (taskId=${taskInput.taskId}). " +
                        "Level: $oldLevel->$newLevel, XP: ${leader.xp}->${updatedLeader.xp}"
                    }

                    // Broadcast level up if player leveled up
                    if (newLevelPts > 0) {
                        val playerProfile = serverContext.playerAccountRepository.getProfileOfPlayerId(connection.playerId).getOrNull()
                        val playerName = playerProfile?.displayName ?: connection.playerId
                        BroadcastService.broadcastUserLevel(playerName, newLevel)
                    }
                } else {
                    Logger.error(LogConfigSocketError) {
                        "Failed to load PlayerObjects for instant junk removal XP grant playerId=${connection.playerId}"
                    }
                }
            } catch (e: Exception) {
                Logger.error(LogConfigSocketError) {
                    "Failed to grant XP for instant junk removal playerId=${connection.playerId}: ${e.message}"
                }
            }
        }

        connection.sendMessage(NetworkMessage.TASK_COMPLETE, taskInput.taskId)
        server.handler.save.compound.task.TaskSaveHandler.cleanupJunkRemovalTask(taskInput.taskId)
    }

    // calculateLevel() function removed - now using XpLevelService.addXpToLeader() instead
}

data class JunkRemovalParameter(
    var taskId: String = "",
    var buildingId: String = "",
    var removalDuration: Duration = Duration.ZERO,
    var xpReward: Int = 0
)

data class JunkRemovalStopParameter(
    var taskId: String = "",
)
