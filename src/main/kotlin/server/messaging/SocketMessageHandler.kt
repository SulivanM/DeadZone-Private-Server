package server.messaging

import server.messaging.HandlerContext

/**
 * Interface for handling socket messages from game clients.
 *
 * Implementations of this interface process specific message types from the client
 * and generate appropriate responses. The server uses a dispatcher pattern to route
 * incoming messages to the correct handler based on message type matching.
 *
 * ## Usage Example
 *
 * ```kotlin
 * class PingHandler : SocketMessageHandler {
 *     override fun match(message: SocketMessage): Boolean {
 *         return message.type == "ping"
 *     }
 *
 *     override suspend fun handle(ctx: HandlerContext) {
 *         // Send pong response
 *         ctx.connection.send(ctx.connection.createMessage("pong"))
 *     }
 * }
 * ```
 *
 * ## Registration
 *
 * Handlers must be registered in [server.GameServer.initialize]:
 * ```kotlin
 * socketDispatcher.register(PingHandler())
 * ```
 *
 * @see server.handler.JoinHandler Example handler for client connection
 * @see server.handler.DefaultHandler Fallback handler for unknown messages
 * @see server.messaging.SocketMessageDispatcher Message routing implementation
 */
interface SocketMessageHandler {
    /**
     * Determines if this handler should process the given message.
     *
     * @param message The incoming socket message to evaluate
     * @return `true` if this handler can process the message, `false` otherwise
     */
    fun match(message: SocketMessage): Boolean

    /**
     * Processes the socket message and generates appropriate response.
     *
     * This method is called when [match] returns true. Implementations should:
     * 1. Validate message parameters
     * 2. Perform required business logic
     * 3. Send response(s) to the client via [HandlerContext.connection]
     * 4. Handle errors gracefully
     *
     * @param ctx Context containing connection, message, and server state
     */
    suspend fun handle(ctx: HandlerContext)
}
