package server.handler

import context.ServerContext
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler

/**
 * Handle `de` (Debug) message.
 *
 * AS3 Client: connection.send("de", url, errorMessage)
 * Format: ["de", "http://example.com/game.swf", "TypeError: null"]
 *
 * Fire-and-forget message for logging client errors and debug info.
 * Sent when client encounters errors or during development debugging.
 */
class DebugHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == "de"
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "DEBUG: No playerId in connection" }
            return
        }

        // Extract debug data: ["de", url, errorMessage]
        val url = message.getString(0) ?: "unknown"
        val errorMessage = message.getString(1) ?: ""

        // Log debug information
        Logger.info(LogConfigSocketToClient) {
            "DEBUG: Player $playerId from $url - Error: $errorMessage"
        }

        // Store in database for later analysis if needed
        // This helps track client-side issues in production
    }
}
