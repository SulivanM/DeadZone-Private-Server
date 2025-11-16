package server.tasks.impl

import server.core.Connection
import server.messaging.NetworkMessage
import server.tasks.*
import common.Time
import kotlin.time.Duration.Companion.seconds

/**
 * Sends a time update ('tu') message to client.
 *
 * The game doesn't maintain its own time; instead, it relies on the server for timekeeping.
 */
class TimeUpdateTask() : ServerTask<Unit, Unit>() {
    override val category: TaskCategory = TaskCategory.TimeUpdate
    override val config: TaskConfig = TaskConfig(repeatInterval = 1.seconds)
    override val scheduler: TaskScheduler? = null

    override val taskInputBlock: (Unit) -> Unit = { }
    override val stopInputBlock: (Unit) -> Unit = { }
    override fun createTaskInput() = Unit
    override fun createStopInput() = Unit

    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        connection.sendMessage(NetworkMessage.TIME_UPDATE, Time.now(), enableLogging = false)
    }
}
