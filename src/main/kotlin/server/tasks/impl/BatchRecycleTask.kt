package server.tasks.impl

import context.ServerContext
import context.requirePlayerContext
import server.core.Connection
import server.messaging.NetworkMessage
import server.tasks.*
import common.LogConfigSocketError
import common.Logger
import kotlin.time.Duration

class BatchRecycleCompleteTask(
    override val taskInputBlock: BatchRecycleCompleteParameter.() -> Unit,
    override val stopInputBlock: BatchRecycleCompleteStopParameter.() -> Unit
) : ServerTask<BatchRecycleCompleteParameter, BatchRecycleCompleteStopParameter>() {
    private val taskInput: BatchRecycleCompleteParameter by lazy {
        createTaskInput().apply(taskInputBlock)
    }

    override val category = TaskCategory.BatchRecycle.Complete
    override val config = TaskConfig(
        startDelay = taskInput.duration
    )
    override val scheduler: TaskScheduler? = null

    override fun createTaskInput(): BatchRecycleCompleteParameter = BatchRecycleCompleteParameter()
    override fun createStopInput(): BatchRecycleCompleteStopParameter = BatchRecycleCompleteStopParameter()

    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        val serverContext = taskInput.serverContext
        if (serverContext != null) {
            val services = serverContext.requirePlayerContext(connection.playerId).services
            val job = services.batchRecycleJob.getBatchRecycleJob(taskInput.jobId)
            
            if (job != null) {
                services.inventory.updateInventory { items ->
                    items + job.items
                }
                
                val removeResult = services.batchRecycleJob.removeBatchRecycleJob(taskInput.jobId)
                if (removeResult.isFailure) {
                    Logger.error(LogConfigSocketError) {
                        "Failed to remove batch recycle job jobId=${taskInput.jobId}, playerId=${connection.playerId}: ${removeResult.exceptionOrNull()?.message}"
                    }
                }
            }
        }
        connection.sendMessage(NetworkMessage.BATCH_RECYCLE_COMPLETE, taskInput.jobId)
    }
}

data class BatchRecycleCompleteParameter(
    var jobId: String = "",
    var duration: Duration = Duration.ZERO,
    var serverContext: ServerContext? = null
)

data class BatchRecycleCompleteStopParameter(
    var jobId: String = "",
)
