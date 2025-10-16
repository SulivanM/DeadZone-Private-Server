package socket.tasks.impl

import socket.core.Connection
import socket.messaging.NetworkMessage
import socket.tasks.*
import utils.Time
import kotlin.time.Duration.Companion.seconds

/**
 * Sends a time update ('tu') message to client.
 *
 * The game doesn't maintain its own time; instead, it relies on the server for timekeeping.
 */
class TimeUpdateTask(private val connection: Connection) : ServerTask<Unit, Unit>() {
    override val category: TaskCategory = TaskCategory.TimeUpdate
    override val config: TaskConfig = TaskConfig(repeatInterval = 1.seconds)
    override val scheduler: TaskScheduler? = null

    // playerId123-TU
    override fun deriveId(): String {
        return "${connection.playerId}-${category.code}"
    }

    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        connection.sendMessage(NetworkMessage.TIME_UPDATE, Time.now(), enableLogging = false)
    }
}
