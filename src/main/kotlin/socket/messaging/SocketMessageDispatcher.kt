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
        Logger.info { "Finding handler for type: ${msg.type} | message: $msg" }
        return (handlers.find { it.match(msg) } ?: DefaultHandler()).also {
            Logger.info {"Dispatching to $it" }
        }
    }

    fun shutdown() {
        handlers.clear()
    }
}
