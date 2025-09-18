package socket.handler

import socket.core.Connection
import socket.messaging.SocketMessage
import socket.messaging.SocketMessageHandler
import socket.protocol.PIOSerializer
import utils.LogConfigSocketError
import utils.Logger

class DefaultHandler() : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return true
    }

    override suspend fun handle(
        connection: Connection,
        message: SocketMessage,
        send: suspend (ByteArray) -> Unit
    ) {
        Logger.warn(LogConfigSocketError) { "Handler not registered or implemented for message: $message" }
        send(PIOSerializer.serialize(listOf("\u0000\u0000\u0000\u0000")))
    }
}
