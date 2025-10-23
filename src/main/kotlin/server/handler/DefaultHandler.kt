package server.handler

import dev.deadzone.socket.messaging.HandlerContext
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer
import utils.LogConfigSocketError
import utils.Logger

class DefaultHandler() : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return true
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        Logger.warn(LogConfigSocketError) {
            "Handler of type=${message.msgTypeToString()} is either unregistered (register it on GameServer.kt) or unimplemented"
        }
        send(PIOSerializer.serialize(listOf("\u0000\u0000\u0000\u0000")))
    }
}
