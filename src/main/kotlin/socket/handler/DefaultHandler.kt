package dev.deadzone.socket.handler

import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.messaging.SocketMessage
import dev.deadzone.socket.messaging.SocketMessageHandler
import dev.deadzone.socket.protocol.PIOSerializer
import dev.deadzone.utils.LogConfigSocketError
import dev.deadzone.utils.Logger

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
