package server.tasks

import server.core.Connection

/**
 * Represents a component that handles timing, repetition, and lifecycle of a task as defined by [TaskConfig].
 *
 * By default, scheduling is handled by [ServerTaskDispatcher].
 * However, individual [ServerTask] implementations may override this behavior
 * if they require custom scheduling logic or more complex timing control.
 */
interface TaskScheduler {
    suspend fun <TaskInput : Any, StopInput : Any> schedule(
        connection: Connection,
        taskId: String,
        task: ServerTask<TaskInput, StopInput>
    )
}

/**
 * [ServerTask] has lifecycle hooks (e.g., `onStart`, `onComplete`) which are intended to be used
 * by a [TaskScheduler] and the subclass itself implementing the methods.
 *
 * This annotation gives a warning for caller that tries to call lifecycle hooks directly from a [ServerTask] implementation.
 *
 * Don't do something like:
 * ```
 * BuildingTask.BuildingCreate {
 *     buildingId = "bld123"
 * }.execute()
 * ```
 */
@RequiresOptIn(
    level = RequiresOptIn.Level.ERROR,
    message = "This API is only intended to be called by task scheduler."
)
@Retention(AnnotationRetention.BINARY)
annotation class InternalTaskAPI
