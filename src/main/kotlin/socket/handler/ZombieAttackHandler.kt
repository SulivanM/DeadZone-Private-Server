package socket.handler

import socket.protocol.PIOSerializer
import socket.core.Connection
import socket.messaging.NetworkMessage
import socket.messaging.SocketMessage
import socket.messaging.SocketMessageHandler

class ZombieAttackHandler(): SocketMessageHandler {
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
