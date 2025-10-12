package socket.handler

import context.ServerContext
import dev.deadzone.socket.messaging.HandlerContext
import socket.messaging.NetworkMessage
import socket.messaging.SocketMessage
import socket.messaging.SocketMessageHandler
import socket.tasks.TaskTemplate

/**
 * Handle `ic` message by:
 *
 * 1. Do the necessary setup in server.
 *
 * Very important signal sent by client. It doesn't expects a response, so likely a one-way signal.
 * In here the game is guaranteed to be loaded (in timeline screen). So we could do some setup here.
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
        serverContext.taskDispatcher.runTask(
            connection = connection,
            taskTemplateKey = TaskTemplate.TIME_UPDATE,
            cfgBuilder = { null },
            onComplete = {}
        )

        Unit
    }
}
