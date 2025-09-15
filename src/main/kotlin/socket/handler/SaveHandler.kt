package dev.deadzone.socket.handler

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.messaging.NetworkMessage
import dev.deadzone.socket.messaging.SocketMessage
import dev.deadzone.socket.messaging.SocketMessageHandler
import dev.deadzone.utils.LogConfigSocketError
import dev.deadzone.utils.Logger
import dev.deadzone.utils.Time

/**
 * Handle `save` message by:
 *
 * 1. Receive the `data`, `_type`, and `id` (save id) for the said message.
 * 2. Route the save into the corresponding handler based on `_type`.
 * 3. Handlers determine what to do based on the given `data`.
 * 4. Optionally, response back a message of type 'r' with the expected JSON payload and the given save id.
 */
class SaveHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.contains(NetworkMessage.SAVE) or (message.type?.equals(NetworkMessage.SAVE) == true)
    }

    @Suppress("UNCHECKED_CAST")
    override suspend fun handle(
        connection: Connection,
        message: SocketMessage,
        send: suspend (ByteArray) -> Unit
    ) {
        val body = message.getMap(NetworkMessage.SAVE) ?: emptyMap()
        val data = body["data"] as? Map<String, Any?> ?: emptyMap()
        val type = data["_type"] as String? ?: return
        val saveId = body["id"] as String? ?: return
        val pid = requireNotNull(connection.playerId) { "Missing playerId on save message for connection=$connection" }

        // Note: the game typically send and expects JSON data for save message
        // encode JSON response to string before using PIO serialization

        var match = false
        // 15 save handlers
        serverContext.saveHandlers.forEach { saveHandler ->
            // O(1) hashset check on each handlers
            if (type in saveHandler.supportedTypes) {
                match = true
                // further string matching on the type on each handler
                saveHandler.handle(connection, type, saveId, data, send, serverContext)
            }
        }

        if (!match) {
            Logger.warn(LogConfigSocketError) { "Handled 's' network message but unrouted for save type: $type with data=$data" }
        }
    }
}

fun buildMsg(saveId: String?, vararg payloads: Any): List<Any> {
    return buildList {
        add("r")
        add(saveId ?: "m")
        add(Time.now())
        addAll(payloads)
    }
}
