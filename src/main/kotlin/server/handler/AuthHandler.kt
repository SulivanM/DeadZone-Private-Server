package server.handler

import dev.deadzone.socket.messaging.HandlerContext
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import utils.LogConfigSocketToClient
import utils.Logger

/**
 * Auth message is send after game ready message.
 * 'auth' contains MD5 hash produced from hashing all binaries sent in the join message.
 */
class AuthHandler() : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == "auth" || message.contains("auth")
    }

    override suspend fun handle(ctx: HandlerContext) {
        Logger.info(LogConfigSocketToClient) { "Received auth message, ignoring." }
    }
}
