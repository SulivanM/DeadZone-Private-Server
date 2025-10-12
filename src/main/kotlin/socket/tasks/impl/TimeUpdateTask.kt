package socket.tasks.impl

import socket.core.Connection
import socket.messaging.NetworkMessage
import socket.tasks.ServerTask
import socket.tasks.TaskConfig
import socket.tasks.TaskTemplate
import socket.tasks.TaskScheduler
import utils.Time
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds

/**
 * Sends a time update ('tu') message to client.
 *
 * The game doesn't maintain its own time; instead, it relies on the server for timekeeping.
 */
class TimeUpdateTask() : ServerTask {
    override val key: TaskTemplate
        get() = TaskTemplate.TIME_UPDATE

    override val config: TaskConfig
        get() = TaskConfig(
            targetTask = NetworkMessage.TIME_UPDATE,
            initialRunDelay = 1.seconds,
            repeatDelay = 1000.milliseconds,
            extra = emptyMap(),
        )

    override val scheduler: TaskScheduler?
        get() = null

    override suspend fun run(connection: Connection, finalConfig: TaskConfig) {
        connection.sendMessage(finalConfig.targetTask, Time.now(), enableLogging = false)
    }
}
