package dev.deadzone.socket.tasks

import dev.deadzone.socket.core.Connection

/**
 * A template of task which can be run flexibly
 *
 * Implementations of this interface can push data to clients through client's [Connection]
 * if needed.
 *
 * We may need to implement sort of queue system for task that needs to be run.
 * During LoadObjects, we re-check the game timers. We don't want to send BUILDING_COMPLETE message
 * if the building completes while the game is in loading, hence the idea of making queued task.
 *
 * Open the queue and run all tasks when the game reached INIT_COMPLETE
 */
interface ServerTask {
    /**
     * Unique identifier for each task template
     */
    val key: TaskTemplate

    /**
     * Default config for the task.
     */
    val config: TaskConfig

    /**
     * A scheduler override from the default [ServerTaskDispatcher].
     */
    val scheduler: TaskScheduler?

    /**
     * Run the task. Task do not need to schedule its running as scheduling is done by [TaskScheduler]
     *
     * @param connection the player's socket connection to send message if needed.
     */
    suspend fun run(connection: Connection, finalConfig: TaskConfig)
}
