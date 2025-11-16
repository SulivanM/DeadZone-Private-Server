package server.handler

import server.messaging.HandlerContext
import server.protocol.PIOSerializer
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler

class ZombieAttackHandler(): SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.contains(NetworkMessage.REQUEST_ZOMBIE_ATTACK)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val message = listOf(NetworkMessage.ZOMBIE_ATTACK)
        send(PIOSerializer.serialize(message))
    }
}
