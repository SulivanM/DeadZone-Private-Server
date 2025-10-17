package dev.deadzone.socket.tasks.impl

import socket.core.Connection
import socket.messaging.NetworkMessage
import socket.tasks.InternalTaskAPI
import socket.tasks.ServerTask
import socket.tasks.TaskCategory
import socket.tasks.TaskConfig
import socket.tasks.TaskScheduler
import kotlin.time.Duration

/**
 * Task for creating and upgrading building with or without cash option.
 *
 * This is used for:
 * - MISSION_RETURN_COMPLETE (used in MISSION_END)
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
     * Main execution: waits until `buildDuration` then run `execute()`,
     * which will send BUILDING_COMPLETE message to client.
     */
    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        connection.sendMessage(NetworkMessage.MISSION_RETURN_COMPLETE, taskInput.missionId)
    }
}

data class MissionReturnParameter(
    var missionId: String = "",
    var returnTime: Duration = Duration.ZERO
)

data class MissionReturnStopParameter(
    var missionId: String = ""
)