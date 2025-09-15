package dev.deadzone.socket.handler.save.quest

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class QuestSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.QUEST_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        when (type) {
            SaveDataMethod.QUEST_COLLECT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'QUEST_COLLECT' message [not implemented]" }
            }

            SaveDataMethod.QUEST_TRACK -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'QUEST_TRACK' message [not implemented]" }
            }

            SaveDataMethod.QUEST_UNTRACK -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'QUEST_UNTRACK' message [not implemented]" }
            }

            SaveDataMethod.QUEST_DAILY_DECLINE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'QUEST_DAILY_DECLINE' message [not implemented]" }
            }

            SaveDataMethod.QUEST_DAILY_ACCEPT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'QUEST_DAILY_ACCEPT' message [not implemented]" }
            }

            SaveDataMethod.REPEAT_ACHIEVEMENT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'REPEAT_ACHIEVEMENT' message [not implemented]" }
            }

            SaveDataMethod.GLOBAL_QUEST_COLLECT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'GLOBAL_QUEST_COLLECT' message [not implemented]" }
            }
        }
    }
}
