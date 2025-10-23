package server.handler.save.arena

import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import utils.LogConfigSocketToClient
import utils.Logger

class ArenaSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.ARENA_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.ARENA_START -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ARENA_START' message [not implemented]" }
            }

            SaveDataMethod.ARENA_CONTINUE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ARENA_CONTINUE' message [not implemented]" }
            }

            SaveDataMethod.ARENA_FINISH -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ARENA_FINISH' message [not implemented]" }
            }

            SaveDataMethod.ARENA_ABORT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ARENA_ABORT' message [not implemented]" }
            }

            SaveDataMethod.ARENA_DEATH -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ARENA_DEATH' message [not implemented]" }
            }

            SaveDataMethod.ARENA_UPDATE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ARENA_UPDATE' message [not implemented]" }
            }

            SaveDataMethod.ARENA_LEADER -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ARENA_LEADER' message [not implemented]" }
            }

            SaveDataMethod.ARENA_LEADERBOARD -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ARENA_LEADERBOARD' message [not implemented]" }
            }
        }
    }
}
