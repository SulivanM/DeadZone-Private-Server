package socket.tasks.impl

import socket.core.Connection
import socket.messaging.NetworkMessage
import socket.tasks.*
import kotlin.time.Duration

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
        connection.sendMessage(NetworkMessage.BUILDING_COMPLETE, taskInput.buildingId)
    }
}

data class BuildingCreateParameter(
    var buildingId: String = "",
    var buildDuration: Duration = Duration.ZERO
)

data class BuildingCreateStopParameter(
    var buildingId: String = "",
)
