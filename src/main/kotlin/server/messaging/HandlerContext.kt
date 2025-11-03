package dev.deadzone.socket.messaging

import server.core.Connection
import server.messaging.SocketMessage

class HandlerContext(
    val connection: Connection,
    val message: SocketMessage
) {
    suspend fun send(
        bytes: ByteArray,
        enableLogging: Boolean = true,
        logFull: Boolean = true
    ) {
        connection.sendRaw(bytes, enableLogging, logFull)
    }

    suspend fun sendMessage(
        type: String,
        vararg args: Any,
        enableLogging: Boolean = true,
        logFull: Boolean = true
    ) {
        connection.sendMessage(type, *args, enableLogging, logFull)
    }
}
