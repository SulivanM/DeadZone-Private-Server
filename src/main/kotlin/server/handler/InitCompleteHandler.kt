package server.handler

import context.ServerContext
import dev.deadzone.socket.messaging.HandlerContext
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.tasks.impl.TimeUpdateTask

/**
 * Handle `ic` message by:
 *
 * 1. Do the necessary setup in server.
 * 2. Send data update to client if necessary.
 *
 * INIT_COMPLETE is a signal sent by client to notify server that the player's game is now active.
 */
class InitCompleteHandler(private val serverContext: ServerContext) :
    SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        // IC message is null, so only check for "ic" present
        return message.contains(NetworkMessage.INIT_COMPLETE)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        // When game init is completed, mark player as active
        serverContext.onlinePlayerRegistry.markOnline(connection.playerId)

        // send serverTime to client
        serverContext.taskDispatcher.runTaskFor(
            connection = connection,
            taskToRun = TimeUpdateTask()
        )
    }
}
