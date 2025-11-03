package server.handler

import context.ServerContext
import dev.deadzone.socket.messaging.HandlerContext
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.tasks.impl.TimeUpdateTask

class InitCompleteHandler(private val serverContext: ServerContext) :
    SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        
        return message.contains(NetworkMessage.INIT_COMPLETE)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        
        serverContext.onlinePlayerRegistry.markOnline(connection.playerId)

        serverContext.taskDispatcher.runTaskFor(
            connection = connection,
            taskToRun = TimeUpdateTask()
        )
    }
}
