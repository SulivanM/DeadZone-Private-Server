package dev.deadzone.socket.handler

import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.messaging.SocketMessage
import dev.deadzone.socket.messaging.SocketMessageHandler
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

/**
 * Auth message is send after game ready message.
 * 'auth' contains MD5 hash produced from hashing all binaries sent in the join message.
 */
class AuthHandler() : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == "auth" || message.contains("auth")
    }

    override suspend fun handle(
        connection: Connection,
        message: SocketMessage,
        send: suspend (ByteArray) -> Unit
    ) {
        Logger.info(LogConfigSocketToClient) { "Received auth message, ignoring." }
    }
}
