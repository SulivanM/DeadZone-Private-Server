package server.messaging

import server.core.Connection
import server.messaging.SocketMessage

/**
 * Encapsulate objects and data needed by handlers to handle message.
 */
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
