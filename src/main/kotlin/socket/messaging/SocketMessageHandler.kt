package socket.messaging

import dev.deadzone.socket.messaging.HandlerContext

/**
 * A template for socket message handler
 *
 * See example
 * - [socket.handler.JoinHandler]
 * - [socket.handler.DefaultHandler]
 */
interface SocketMessageHandler {
    fun match(message: SocketMessage): Boolean
    suspend fun handle(ctx: HandlerContext)
}
