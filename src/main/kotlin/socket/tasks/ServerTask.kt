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
 * Internally, implementations rely on the low-level `runTask` API
 * provided by [ServerTaskDispatcher] to handle timing and lifecycle control.
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
 * @property category Logical grouping of this task or namespace for this task.
 * @property config Defines timing, delay, and repetition rules for task execution.
 * @property scheduler Optional scheduler for this task.
 *                     Typically, when scheduling is complex, the [ServerTask] itself implements it.
 *
 * @param ExecParam The type of the execution parameter required by this task.
 *                  This is the input used when the task is started.
 *
 * @param StopParam The type of the cancellation parameter for this task.
 *                  Used to deterministically identify or stop a running task
 *                  (for example, a building ID for a construction task).
 */
abstract class ServerTask<ExecParam : Any, StopParam : Any> {
    abstract val category: TaskCategory
    abstract val config: TaskConfig
    abstract val scheduler: TaskScheduler?

    /**
     * Returns a reproducible, deterministic identifier for this task.
     *
     * The derived ID is used for referencing and cancelling tasks consistently
     * across server components. Typically it is derived from a combination of
     * the player ID, [category], and [StopParam] instance (e.g., a `buildingId`).
     *
     * Example:
     * ```
     * override fun deriveId(): String = "${playerId}_${category}_${stopParam.buildingId}"
     * ```
     * for building create task.
     */
    abstract fun deriveId(): String

    /**
     * Called once when the task is first scheduled.
     * Used for setup, initialization, or sending a "start" message to the client.
     */
    @SchedulerOnly
    open suspend fun onStart(connection: Connection) = Unit

    /**
     * Main execution body of the task.
     * Called once or repeatedly depending on [config].
     */
    @SchedulerOnly
    open suspend fun execute(connection: Connection) {
    }

    /**
     * Called before each execution cycle begins (only for repeatable tasks).
     * Useful for preparing per-iteration state or logging progress.
     */
    @SchedulerOnly
    open suspend fun onIterationStart(connection: Connection) = Unit

    /**
     * Called after each execution cycle completes (only for repeatable tasks).
     * Useful for cleanup, progress tracking, or scheduling side effects.
     */
    @SchedulerOnly
    open suspend fun onIterationComplete(connection: Connection) = Unit

    /**
     * Called once when the task finishes all scheduled iterations successfully.
     * For non-repeating tasks, this is invoked immediately after [execute].
     */
    @SchedulerOnly
    open suspend fun onTaskComplete(connection: Connection) = Unit

    /**
     * Called if the task is stopped or cancelled before completing normally.
     * Use this to revert partial state or perform cleanup.
     */
    @SchedulerOnly
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
