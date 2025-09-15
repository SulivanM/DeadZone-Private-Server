package dev.deadzone.socket.handler.save.arena

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class ArenaSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.ARENA_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
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
