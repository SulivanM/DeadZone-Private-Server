package dev.deadzone.socket.tasks

import context.ServerContext
import socket.core.Connection
import socket.tasks.ServerTask
import socket.tasks.ServerTaskDispatcher
import socket.tasks.TaskCategory

/**
 * Server-level component that bridges between [ServerTaskDispatcher] and an implementation of [ServerTask].
 *
 * Provides a type-safe API for starting and stopping tasks without requiring direct access
 * to [ServerTaskDispatcher] or [ServerContext].
 *
 * Can add tasks queue in the future if needed.
 *
 */
class ServerTaskRunner(
    private val dispatcher: ServerTaskDispatcher
) {

    /**
     * Tell the dispatcher to start the [task] for the specific player's [Connection]
     */
    fun <ExecParam : Any, StopParam : Any> startFor(
        connection: Connection,
        task: ServerTask<ExecParam, StopParam>
    ) {
        dispatcher.runTask(connection, task)
    }

    /**
     * Tell the dispatcher to stop the a particular task by ID derived from
     * [Connection.playerId], [category], and [stopParam] for the specific player's [Connection].
     */
    fun <StopParam : Any> stopFor(
        connection: Connection,
        category: TaskCategory,
        stopParam: StopParam
    ) {
        val taskId = dispatcher.deriveTaskId(connection.playerId, category, stopParam)
        dispatcher.stopTask(taskId)
    }
}
