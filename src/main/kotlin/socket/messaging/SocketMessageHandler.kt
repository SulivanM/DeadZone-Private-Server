package socket.messaging

import socket.core.Connection

/**
 * A template for socket message handler
 *
 * See example
 * - [socket.handler.JoinHandler]
 * - [socket.handler.DefaultHandler]
 */
interface SocketMessageHandler {
    fun match(message: SocketMessage): Boolean
    suspend fun handle(connection: Connection, message: SocketMessage, send: suspend (ByteArray) -> Unit)
}
