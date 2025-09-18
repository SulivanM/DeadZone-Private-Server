package socket.handler

import socket.protocol.PIOSerializer
import socket.core.Connection
import socket.messaging.NetworkMessage
import socket.messaging.SocketMessage
import socket.messaging.SocketMessageHandler

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

    override suspend fun handle(connection: Connection, message: SocketMessage, send: suspend (ByteArray) -> Unit) {
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
