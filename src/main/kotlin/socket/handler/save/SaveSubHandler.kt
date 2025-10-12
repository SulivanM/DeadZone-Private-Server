package socket.handler.save

import dev.deadzone.socket.handler.save.SaveHandlerContext

interface SaveSubHandler {
    val supportedTypes: Set<String>
    suspend fun handle(ctx: SaveHandlerContext)
}
