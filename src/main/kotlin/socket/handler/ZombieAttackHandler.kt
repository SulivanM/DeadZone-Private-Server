package dev.deadzone.socket.handler

import dev.deadzone.socket.protocol.PIOSerializer
import dev.deadzone.socket.core.Connection
import dev.deadzone.context.ServerContext
import dev.deadzone.socket.messaging.NetworkMessage
import dev.deadzone.socket.messaging.SocketMessage
import dev.deadzone.socket.messaging.SocketMessageHandler

class ZombieAttackHandler(private val serverContext: ServerContext): SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.contains(NetworkMessage.REQUEST_ZOMBIE_ATTACK)
    }

    override suspend fun handle(
        connection: Connection,
        message: SocketMessage,
        send: suspend (ByteArray) -> Unit
    ) {
        val message = listOf(NetworkMessage.ZOMBIE_ATTACK)
        send(PIOSerializer.serialize(message))
    }
}
