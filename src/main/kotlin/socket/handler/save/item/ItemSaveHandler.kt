package dev.deadzone.socket.handler.save.item

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class ItemSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.ITEM_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        when (type) {
            SaveDataMethod.ITEM -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM' message [not implemented]" }
            }

            SaveDataMethod.ITEM_BUY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_BUY' message [not implemented]" }
            }

            SaveDataMethod.ITEM_LIST -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_LIST' message [not implemented]" }
            }

            SaveDataMethod.ITEM_RECYCLE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_RECYCLE' message [not implemented]" }
            }

            SaveDataMethod.ITEM_DISPOSE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_DISPOSE' message [not implemented]" }
            }

            SaveDataMethod.ITEM_CLEAR_NEW -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_CLEAR_NEW' message [not implemented]" }
            }

            SaveDataMethod.ITEM_BATCH_RECYCLE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_BATCH_RECYCLE' message [not implemented]" }
            }

            SaveDataMethod.ITEM_BATCH_RECYCLE_SPEED_UP -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_BATCH_RECYCLE_SPEED_UP' message [not implemented]" }
            }

            SaveDataMethod.ITEM_BATCH_DISPOSE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_BATCH_DISPOSE' message [not implemented]" }
            }
        }
    }
}
