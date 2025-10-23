package server.handler.save.chat

import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import utils.LogConfigSocketToClient
import utils.Logger

class ChatSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.CHAT_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.CHAT_SILENCED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_SILENCED' message [not implemented]" }
            }

            SaveDataMethod.CHAT_KICKED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_KICKED' message [not implemented]" }
            }

            SaveDataMethod.CHAT_GET_CONTACTS_AND_BLOCKS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_GET_CONTACTS_AND_BLOCKS' message [not implemented]" }
            }

            SaveDataMethod.CHAT_MIGRATE_CONTACTS_AND_BLOCKS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_MIGRATE_CONTACTS_AND_BLOCKS' message [not implemented]" }
            }

            SaveDataMethod.CHAT_ADD_CONTACT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_ADD_CONTACT' message [not implemented]" }
            }

            SaveDataMethod.CHAT_REMOVE_CONTACT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_REMOVE_CONTACT' message [not implemented]" }
            }

            SaveDataMethod.CHAT_REMOVE_ALL_CONTACTS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_REMOVE_ALL_CONTACTS' message [not implemented]" }
            }

            SaveDataMethod.CHAT_ADD_BLOCK -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_ADD_BLOCK' message [not implemented]" }
            }

            SaveDataMethod.CHAT_REMOVE_BLOCK -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_REMOVE_BLOCK' message [not implemented]" }
            }

            SaveDataMethod.CHAT_REMOVE_ALL_BLOCKS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHAT_REMOVE_ALL_BLOCKS' message [not implemented]" }
            }
        }
    }
}
