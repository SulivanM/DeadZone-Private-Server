package server.tasks

import server.core.Connection

interface TaskScheduler {
    suspend fun <TaskInput : Any, StopInput : Any> schedule(
        connection: Connection,
        taskId: String,
        task: ServerTask<TaskInput, StopInput>
    )
}

@RequiresOptIn(
    level = RequiresOptIn.Level.ERROR,
    message = "This API is only intended to be called by task scheduler."
)
@Retention(AnnotationRetention.BINARY)
annotation class InternalTaskAPI
