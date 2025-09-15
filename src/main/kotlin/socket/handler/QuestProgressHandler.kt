package dev.deadzone.socket.handler

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.protocol.PIOSerializer
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.messaging.NetworkMessage
import dev.deadzone.socket.messaging.SocketMessage
import dev.deadzone.socket.messaging.SocketMessageHandler

/**
 * Handle `qp` message by:
 *
 * 1. Sending quest progress JSON
 *
 */
class QuestProgressHandler(private val serverContext: ServerContext) : SocketMessageHandler {
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
