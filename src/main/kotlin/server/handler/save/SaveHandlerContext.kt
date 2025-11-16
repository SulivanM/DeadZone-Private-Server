package server.handler.save

import context.ServerContext
import server.core.Connection

/**
 * Encapsulate objects and data needed by save handlers to handle message.
 */
class SaveHandlerContext(
    val connection: Connection,
    val type: String,
    val saveId: String,
    val data: Map<String, Any?>,
    val serverContext: ServerContext,
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
