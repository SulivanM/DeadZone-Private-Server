package socket.handler

import dev.deadzone.socket.messaging.HandlerContext
import socket.protocol.PIOSerializer
import socket.messaging.NetworkMessage
import socket.messaging.SocketMessage
import socket.messaging.SocketMessageHandler

class ZombieAttackHandler(): SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.contains(NetworkMessage.REQUEST_ZOMBIE_ATTACK)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val message = listOf(NetworkMessage.ZOMBIE_ATTACK)
        send(PIOSerializer.serialize(message))
    }
}
