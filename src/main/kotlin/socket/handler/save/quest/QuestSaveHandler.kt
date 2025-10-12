package socket.handler.save.quest

import dev.deadzone.socket.handler.save.SaveHandlerContext
import socket.handler.save.SaveSubHandler
import socket.messaging.SaveDataMethod
import utils.LogConfigSocketToClient
import utils.Logger

class QuestSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.QUEST_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
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
