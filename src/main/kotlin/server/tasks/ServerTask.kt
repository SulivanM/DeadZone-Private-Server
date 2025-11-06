package server.tasks

import server.core.Connection

abstract class ServerTask<TaskInput : Any, StopInput : Any> {
    abstract val category: TaskCategory
    abstract val config: TaskConfig
    abstract val scheduler: TaskScheduler?

    abstract val taskInputBlock: TaskInput.() -> Unit
    abstract val stopInputBlock: StopInput.() -> Unit
    abstract fun createTaskInput(): TaskInput
    abstract fun createStopInput(): StopInput

    @InternalTaskAPI
    open suspend fun onStart(connection: Connection) = Unit

    @InternalTaskAPI
    open suspend fun execute(connection: Connection) {
    }

    @InternalTaskAPI
    open suspend fun onIterationStart(connection: Connection) = Unit

    @InternalTaskAPI
    open suspend fun onIterationComplete(connection: Connection) = Unit

    @InternalTaskAPI
    open suspend fun onTaskComplete(connection: Connection) = Unit

    @InternalTaskAPI
    open suspend fun onForceComplete(connection: Connection) {
        onTaskComplete(connection)
    }

    @InternalTaskAPI
    open suspend fun onCancelled(connection: Connection, reason: CancellationReason) = Unit
}

enum class CancellationReason {
    
    MANUAL,

    TIMEOUT,

    ERROR
}
