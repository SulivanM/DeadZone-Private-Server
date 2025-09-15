package dev.deadzone.socket.messaging

import dev.deadzone.socket.core.Connection

/**
 * A template for socket message handler
 *
 * See example
 * - [dev.deadzone.socket.handler.JoinHandler]
 * - [dev.deadzone.socket.handler.DefaultHandler]
 */
interface SocketMessageHandler {
    fun match(message: SocketMessage): Boolean
    suspend fun handle(connection: Connection, message: SocketMessage, send: suspend (ByteArray) -> Unit)
}
