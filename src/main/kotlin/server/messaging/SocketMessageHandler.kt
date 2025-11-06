package server.messaging

import dev.deadzone.socket.messaging.HandlerContext

interface SocketMessageHandler {
    fun match(message: SocketMessage): Boolean
    suspend fun handle(ctx: HandlerContext)
}
