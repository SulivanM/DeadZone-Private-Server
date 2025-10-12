package socket.messaging

import socket.handler.DefaultHandler
import utils.Logger

/**
 * Dispatch [SocketMessage] to a registered handler
 */
class SocketMessageDispatcher() {
    private val handlers = mutableListOf<SocketMessageHandler>()

    fun register(handler: SocketMessageHandler) {
        handlers.add(handler)
    }

    fun findHandlerFor(msg: SocketMessage): SocketMessageHandler {
        return (handlers.find { it.match(msg) } ?: DefaultHandler()).also {
            Logger.debug { "Handled by $it, type=${msg.type} | message=$msg" }
        }
    }

    fun shutdown() {
        handlers.clear()
    }
}
