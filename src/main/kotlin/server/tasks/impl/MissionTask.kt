package server.tasks.impl

import context.ServerContext
import server.core.Connection
import server.messaging.NetworkMessage
import server.tasks.InternalTaskAPI
import server.tasks.ServerTask
import server.tasks.TaskCategory
import server.tasks.TaskConfig
import server.tasks.TaskScheduler
import common.Logger
import common.LogConfigSocketError
import kotlin.time.Duration

/**
 * Task for mission return timer.
 *
 * This is used for:
 * - MISSION_RETURN_COMPLETE (used in MISSION_END)
 *
 * When the return timer completes:
 * 1. Sends MISSION_RETURN_COMPLETE message to client
 * 2. Updates mission in database to mark it as completed
 */
class MissionReturnTask(
    override val taskInputBlock: MissionReturnParameter.() -> Unit,
    override val stopInputBlock: MissionReturnStopParameter.() -> Unit
) : ServerTask<MissionReturnParameter, MissionReturnStopParameter>() {
    private val taskInput: MissionReturnParameter by lazy {
        createTaskInput().apply(taskInputBlock)
    }

    override val category = TaskCategory.Mission.Return
    override val config = TaskConfig(
        startDelay = taskInput.returnTime
    )
    override val scheduler: TaskScheduler? = null

    override fun createTaskInput(): MissionReturnParameter = MissionReturnParameter()
    override fun createStopInput(): MissionReturnStopParameter = MissionReturnStopParameter()

    /**
     * Main execution: waits until `returnTime` then run `execute()`,
     * which will send MISSION_RETURN_COMPLETE message to client and mark mission as completed.
     */
    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        val playerId = connection.playerId
        val missionId = taskInput.missionId

        // Send mission return complete message to client
        connection.sendMessage(NetworkMessage.MISSION_RETURN_COMPLETE, missionId)

        // Update mission in database to mark as completed
        val serverContext = taskInput.serverContext
        if (serverContext != null) {
            val playerObjects = serverContext.db.loadPlayerObjects(playerId)

            if (playerObjects != null) {
                val missions = playerObjects.missions ?: emptyList()
                val updatedMissions = missions.map { mission ->
                    if (mission.id == missionId) {
                        mission.copy(completed = true)
                    } else {
                        mission
                    }
                }

                val updatedPlayerObjects = playerObjects.copy(missions = updatedMissions)
                val updateResult = runCatching {
                    serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                }

                if (updateResult.isFailure) {
                    Logger.error(LogConfigSocketError) {
                        "Failed to mark mission $missionId as completed for playerId=$playerId: ${updateResult.exceptionOrNull()?.message}"
                    }
                } else {
                    Logger.info { "Mission $missionId marked as completed for playerId=$playerId" }
                }
            }
        }
    }
}

data class MissionReturnParameter(
    var missionId: String = "",
    var returnTime: Duration = Duration.ZERO,
    var serverContext: ServerContext? = null
)

data class MissionReturnStopParameter(
    var missionId: String = ""
)