package dev.deadzone.socket.handler.save

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection

interface SaveSubHandler {
    val supportedTypes: Set<String>

    suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    )
}
