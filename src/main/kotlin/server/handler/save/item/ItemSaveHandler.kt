package server.handler.save.item

import context.requirePlayerContext
import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import utils.LogConfigSocketToClient
import utils.Logger

class ItemSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.ITEM_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
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
                val svc = serverContext.requirePlayerContext(connection.playerId).services

                svc.inventory.updateInventory { items ->
                    items.map { item -> item.copy(new = false) }
                }

                Logger.info(LogConfigSocketToClient) { "Cleared 'new' flag on all items for player ${connection.playerId}" }
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
