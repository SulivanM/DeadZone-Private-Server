package socket.handler

import dev.deadzone.socket.messaging.HandlerContext
import socket.messaging.SocketMessage
import socket.messaging.SocketMessageHandler
import socket.protocol.PIOSerializer
import utils.LogConfigSocketError
import utils.Logger

class DefaultHandler() : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return true
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        Logger.warn(LogConfigSocketError) {
            "Handler is unregistered (see Server.kt) or unimplemented for message: ${message.msgTypeToString()}"
        }
        send(PIOSerializer.serialize(listOf("\u0000\u0000\u0000\u0000")))
    }
}
