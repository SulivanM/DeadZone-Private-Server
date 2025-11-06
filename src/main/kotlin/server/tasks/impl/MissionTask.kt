package dev.deadzone.socket.tasks.impl

import server.core.Connection
import server.messaging.NetworkMessage
import server.tasks.InternalTaskAPI
import server.tasks.ServerTask
import server.tasks.TaskCategory
import server.tasks.TaskConfig
import server.tasks.TaskScheduler
import kotlin.time.Duration

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
