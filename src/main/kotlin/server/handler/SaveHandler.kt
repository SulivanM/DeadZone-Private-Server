package server.handler

import context.ServerContext
import dev.deadzone.socket.handler.save.SaveHandlerContext
import dev.deadzone.socket.messaging.HandlerContext
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import utils.LogConfigSocketError
import utils.Logger
import utils.Time

class SaveHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.contains(NetworkMessage.SAVE) or (message.type?.equals(NetworkMessage.SAVE) == true)
    }

    @Suppress("UNCHECKED_CAST")
    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val body = message.getMap(NetworkMessage.SAVE) ?: emptyMap()
        val data = body["data"] as? Map<String, Any?> ?: emptyMap()
        val type = data["_type"] as String? ?: return
        val saveId = body["id"] as String? ?: return
        requireNotNull(connection.playerId) { "Missing playerId on save message for connection=$connection" }

        var match = false
        
        serverContext.saveHandlers.forEach { saveHandler ->
            
            if (type in saveHandler.supportedTypes) {
                match = true
                
                saveHandler.handle(SaveHandlerContext(connection, type, saveId, data, serverContext))
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
