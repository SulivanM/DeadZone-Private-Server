package dev.deadzone.socket.handler.save.misc

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class MiscSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.MISC_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        when (type) {
            SaveDataMethod.TUTORIAL_PVP_PRACTICE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'TUTORIAL_PVP_PRACTICE' message [not implemented]" }
            }

            SaveDataMethod.TUTORIAL_COMPLETE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'TUTORIAL_COMPLETE' message [not implemented]" }
            }

            SaveDataMethod.GET_OFFERS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'GET_OFFERS' message [not implemented]" }
            }

            SaveDataMethod.NEWS_READ -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'NEWS_READ' message [not implemented]" }
            }

            SaveDataMethod.CLEAR_NOTIFICATIONS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CLEAR_NOTIFICATIONS' message [not implemented]" }
            }

            SaveDataMethod.FLUSH_PLAYER -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'FLUSH_PLAYER' message [not implemented]" }
            }

            SaveDataMethod.SAVE_ALT_IDS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SAVE_ALT_IDS' message [not implemented]" }
            }

            SaveDataMethod.TRADE_DO_TRADE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'TRADE_DO_TRADE' message [not implemented]" }
            }

            SaveDataMethod.GET_INVENTORY_SIZE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'GET_INVENTORY_SIZE' message [not implemented]" }
            }
        }
    }
}
