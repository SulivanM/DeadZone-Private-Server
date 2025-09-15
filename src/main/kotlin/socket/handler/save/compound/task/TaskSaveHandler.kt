package dev.deadzone.socket.handler.save.compound.task

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class TaskSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.COMPOUND_TASK_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        when (type) {
            SaveDataMethod.TASK_STARTED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'TASK_STARTED' message [not implemented]" }
            }

            SaveDataMethod.TASK_CANCELLED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'TASK_CANCELLED' message [not implemented]" }
            }

            SaveDataMethod.TASK_SURVIVOR_ASSIGNED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'TASK_SURVIVOR_ASSIGNED' message [not implemented]" }
            }

            SaveDataMethod.TASK_SURVIVOR_REMOVED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'TASK_SURVIVOR_REMOVED' message [not implemented]" }
            }

            SaveDataMethod.TASK_SPEED_UP -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'TASK_SPEED_UP' message [not implemented]" }
            }
        }
    }
}
