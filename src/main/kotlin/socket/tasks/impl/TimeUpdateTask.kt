package dev.deadzone.socket.tasks.impl

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.messaging.NetworkMessage
import dev.deadzone.socket.tasks.ServerTask
import dev.deadzone.socket.tasks.TaskConfig
import dev.deadzone.socket.tasks.TaskTemplate
import dev.deadzone.socket.tasks.TaskScheduler
import dev.deadzone.utils.Time
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds

/**
 * Sends a time update ('tu') message to client.
 *
 * The game registers callback for such message, though not sure how frequent should we send the message.
 */
class TimeUpdateTask(serverContext: ServerContext) : ServerTask {
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
        connection.sendMessage(finalConfig.targetTask, Time.now())
    }
}
