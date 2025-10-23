package server.tasks

import kotlin.time.Duration

/**
 * Configuration options for controlling task execution timing and repetition.
 *
 * @property startDelay The delay before the task starts its first execution.
 *                      Use `Duration.ZERO` for immediate execution.
 *
 * @property repeatInterval If set, the task will automatically repeat after each execution
 *                          with this interval. If null, the task runs only once.
 *
 * @property maxRepeats Maximum number of repetitions if [repeatInterval] is defined.
 *                      A null value means unlimited repetitions.
 *                      If the task repetition reached this limit, it will be considered as complete (call the `ServerTask.onComplete` hook)
 *
 * @property timeout Optional maximum lifetime of the task.
 *                   If the task runs longer than this duration, it will be automatically cancelled (call the `ServerTask.onCancelled` hook).
 *                   Can serve as a time-based alternative to [maxRepeats].
 *                   Useful as a safeguard against stalled coroutines (e.g., long I/O operations or unexpected hangs).
 *
 * Example:
 * ```
 * // Run once after 5 seconds
 * TaskConfig(startDelay = 5.seconds)
 *
 * // First run after 2 seconds, then every 10 seconds, for 3 times maximum
 * TaskConfig(startDelay = 2.seconds, repeatInterval = 10.seconds, maxRepeats = 3)
 * ```
 */
data class TaskConfig(
    val startDelay: Duration = Duration.ZERO,
    val repeatInterval: Duration? = null,
    val maxRepeats: Int? = null,
    val timeout: Duration? = null
)
