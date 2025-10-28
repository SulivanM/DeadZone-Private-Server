package server.tasks.impl

import core.compound.CompoundService
import server.core.Connection
import server.messaging.NetworkMessage
import server.tasks.*
import kotlin.time.Duration

class JunkRemovalTask(
    private val compoundService: CompoundService,
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
        compoundService.deleteBuilding(taskInput.buildingId)
        connection.sendMessage(NetworkMessage.TASK_COMPLETE, taskInput.taskId)
    }

    @InternalTaskAPI
    override suspend fun onTaskComplete(connection: Connection) {
        server.handler.save.compound.task.TaskSaveHandler.cleanupJunkRemovalTask(taskInput.taskId)
    }

    @InternalTaskAPI
    override suspend fun onForceComplete(connection: Connection) {
        compoundService.deleteBuilding(taskInput.buildingId)
        connection.sendMessage(NetworkMessage.TASK_COMPLETE, taskInput.taskId)
        server.handler.save.compound.task.TaskSaveHandler.cleanupJunkRemovalTask(taskInput.taskId)
    }
}

data class JunkRemovalParameter(
    var taskId: String = "",
    var buildingId: String = "",
    var removalDuration: Duration = Duration.ZERO
)

data class JunkRemovalStopParameter(
    var taskId: String = "",
)
