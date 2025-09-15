package dev.deadzone.socket.tasks

import dev.deadzone.socket.core.Connection

/**
 * Entity that can schedule task.
 *
 * By default, the scheduling of task is done by scheduler default implementation of [ServerTaskDispatcher].
 * However, if task scheduling is complex, the particular [ServerTask] can override the implementation.
 */
interface TaskScheduler {
    suspend fun schedule(task: ServerTask, connection: Connection, cfg: TaskConfig)
}
