package server.tasks

import server.core.Connection

/**
 * Represents a server-side task with a well-defined lifecycle.
 *
 * A task defines its timing, repetition, and behavior through [TaskConfig].
 * Each implementation should contain only the logic specific to that task type.
 *
 * Typically, tasks implement this interface as a reusable template,
 * allowing callers to run them easily without dealing with lower-level scheduling logic.
 *
 * [ServerTask] implementation should be able to provide `stopId`, a reproducible, deterministic identifier for the task.
 * The derived ID is used for referencing and cancelling tasks consistently across server components.
 * Typically it is derived from a combination of the player ID, [category], and [StopInput] instance (e.g., a `buildingId`).
 *
 * Example (register in GameServer.kt)
 * ```
 * context.taskDispatcher.registerStopId(
 *     category = TaskCategory.TimeUpdate,
 *     StopInputFactory = { BuildingStopInputeter() },
 *     deriveId = { playerId, category, _ ->
 *         // "TU-playerId123"
 *         "${category.code}-$playerId"
 *     }
 * )
 * ```
 *
 * ### Lifecycle Overview
 * A task may run once or repeatedly, depending on its configuration.
 *
 * **Non-repeatable task:**
 * ```
 * task.start()
 * ├─ onStart()
 * ├─ ...delay(startDelay) [optional]
 * ├─ execute()
 * └─ onTaskComplete() / onCancelled()
 * ```
 *
 * **Repeatable task:**
 * ```
 * task.start()
 * ├─ onStart()
 * ├─ ...delay(startDelay) [optional]
 * ├─ repeat until cancelled, timeout, or maxRepeats reached:
 * │   ├─ onIterationStart()
 * │   ├─ execute()
 * │   ├─ onIterationComplete()
 * │   └─ ...delay(repeatInterval) [optional]
 * └─ onTaskComplete() / onCancelled()
 * ```
 *
 * Only [execute] must be implemented; all other lifecycle hooks are optional.
 * Each lifecycle callback receives a [Connection] instance, representing the player's connection this task belongs to.
 *
 * @property category  Logical grouping of this task or namespace for this task.
 * @property config    Defines timing, delay, and repetition rules for task execution.
 * @property scheduler Optional scheduler for this task.
 *                     Typically, when scheduling is complex, the [ServerTask] itself implements it.
 *
 * @param TaskInput The type of data required to execute this task.
 * @param StopInput The type of data used to identify and stop this task.
 *
 * @property taskInputBlock DSL block to produce [TaskInput] instance, to produce data needed to execute the task. **Make sure to set every variables here.**
 * @property stopInputBlock DSL block to produce [StopInput] instance, to produce data needed to cancel the task. **Make sure to set every variables here.**
 * @property createTaskInput Applies the [taskInputBlock] block to an empty [TaskInput].
 * @property stopInputBlock Applies the [stopInputBlock] block to an empty [StopInput].
 */
abstract class ServerTask<TaskInput : Any, StopInput : Any> {
    abstract val category: TaskCategory
    abstract val config: TaskConfig
    abstract val scheduler: TaskScheduler?

    abstract val taskInputBlock: TaskInput.() -> Unit
    abstract val stopInputBlock: StopInput.() -> Unit
    abstract fun createTaskInput(): TaskInput
    abstract fun createStopInput(): StopInput

    /**
     * Called once when the task is first scheduled.
     * Used for setup, initialization, or sending a "start" message to the client.
     */
    @InternalTaskAPI
    open suspend fun onStart(connection: Connection) = Unit

    /**
     * Main execution body of the task.
     * Called once or repeatedly depending on [config].
     */
    @InternalTaskAPI
    open suspend fun execute(connection: Connection) {
    }

    /**
     * Called before each execution cycle begins (only for repeatable tasks).
     * Useful for preparing per-iteration state or logging progress.
     */
    @InternalTaskAPI
    open suspend fun onIterationStart(connection: Connection) = Unit

    /**
     * Called after each execution cycle completes (only for repeatable tasks).
     * Useful for cleanup, progress tracking, or scheduling side effects.
     */
    @InternalTaskAPI
    open suspend fun onIterationComplete(connection: Connection) = Unit

    /**
     * Called once when the task finishes all scheduled iterations successfully.
     * For non-repeating tasks, this is invoked immediately after [execute].
     */
    @InternalTaskAPI
    open suspend fun onTaskComplete(connection: Connection) = Unit

    /**
     * Called when a completion is forced.
     *
     * This happens when the task is not yet finished (e.g., still repeating or its start delay has not yet elapsed),
     * but an external source forces the task to complete immediately.
     *
     * By default, it will just call [onTaskComplete] directly.
     * This makes it differ than cancelling the task, as it is not treated as an error or interruption,
     * and it skips to [onTaskComplete] rather than call the [onCancelled].
     *
     * [ServerTask] implementation can replace or add behaviors as needed.
     */
    @InternalTaskAPI
    open suspend fun onForceComplete(connection: Connection) {
        onTaskComplete(connection)
    }

    /**
     * Called if the task is stopped or cancelled before completing normally.
     * Use this to revert partial state or perform cleanup.
     *
     * @param reason The reason why the task was cancelled.
     *               `ServerTask` implementation may handle different cases as needed.
     */
    @InternalTaskAPI
    open suspend fun onCancelled(connection: Connection, reason: CancellationReason) = Unit
}

/**
 * Describe the reason a task is cancelled.
 */
enum class CancellationReason {
    /**
     * Cancelled explicitly by player or server.
     */
    MANUAL,

    /**
     * When a task has to be cancelled because it exceeded its timeout.
     */
    TIMEOUT,

    /**
     * Task failed due to server error.
     */
    ERROR
}
