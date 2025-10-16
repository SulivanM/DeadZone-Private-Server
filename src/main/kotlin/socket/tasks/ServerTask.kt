package socket.tasks

import socket.core.Connection

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
 * Typically it is derived from a combination of the player ID, [category], and [StopParam] instance (e.g., a `buildingId`).
 *
 * Example (register in Server.kt)
 * ```
 * context.taskDispatcher.registerStopId(
 *     category = TaskCategory.TimeUpdate,
 *     stopParamFactory = { BuildingStopParameter() },
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
 * @param ExecParam The type of the execution parameter required by this task.
 *                  This is the input used when the task is started.
 *
 * @param StopParam The type of the cancellation parameter required by this task.
 *                  This is the input used when the task wants to be stopped.
 *
 * @property execParamBlock DSL block to produce [ExecParam] instance.
 * @property stopParamBlock DSL block to produce [StopParam] instance.
 * @property createExecParam Applies the [execParamBlock] block to an empty [ExecParam].
 * @property createStopParam Applies the [stopParamBlock] block to an empty [StopParam].
 */
abstract class ServerTask<ExecParam : Any, StopParam : Any> {
    abstract val category: TaskCategory
    abstract val config: TaskConfig
    abstract val scheduler: TaskScheduler?

    abstract val execParamBlock: (ExecParam) -> Unit
    abstract val stopParamBlock: (StopParam) -> Unit
    abstract fun createExecParam(): ExecParam
    abstract fun createStopParam(): StopParam

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
     * Called if the task is stopped or cancelled before completing normally.
     * Use this to revert partial state or perform cleanup.
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
