package dev.deadzone.socket.tasks

import kotlin.time.Duration

/**
 * The configuration for a particular task.
 */
data class TaskConfig(
    /**
     * The identifier for the task within the template, usually NetworkMessage.
     */
    val targetTask: String,

    /**
     * The time delay before running the task on the first time after its ready.
     * If null task will be run immediately after its ready.
     */
    val initialRunDelay: Duration,

    /**
     * The time delay if the task is repeatable. If null then task only run once.
     */
    val repeatDelay: Duration? = null,

    /**
     * Extra data for task if needed. Usually used when want to send list of PIO message.
     */
    val extra: Map<String, Any>,
)
