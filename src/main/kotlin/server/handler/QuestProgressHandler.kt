package server.handler

import dev.deadzone.socket.messaging.HandlerContext
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer

/**
 * Handle `qp` message by:
 *
 * 1. Sending quest progress JSON
 *
 */
class QuestProgressHandler() : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.getString(NetworkMessage.QUEST_PROGRESS) != null
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val message = listOf(NetworkMessage.QUEST_PROGRESS, questProgressJson.trimIndent())
        send(PIOSerializer.serialize(message))
    }
}

const val questProgressJson = """
{
  "complete": null,
  "progress": null
}
"""
