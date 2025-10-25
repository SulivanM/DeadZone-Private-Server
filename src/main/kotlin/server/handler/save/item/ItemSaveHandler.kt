package server.handler.save.item

import context.requirePlayerContext
import core.items.model.Item
import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import utils.LogConfigSocketToClient
import utils.Logger
import utils.UUID
import kotlin.random.Random

class ItemSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.ITEM_SAVES

    private fun generateRecycleRewards(itemType: String): List<Item> {
        val rewards = mutableListOf<Item>()

        val baseRewards = mapOf(
            "wood" to 2..5,
            "metal" to 1..3,
            "cloth" to 1..4,
            "water" to 1..2
        )

        baseRewards.forEach { (type, range) ->
            if (Random.nextDouble() < 0.3) {
                val qty = Random.nextInt(range.first, range.last + 1).toUInt()
                rewards.add(Item(
                    id = UUID.new(),
                    type = type,
                    qty = qty,
                    new = true
                ))
            }
        }

        return rewards
    }

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
                val itemId = data["id"] as? String
                if (itemId == null) {
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false}""")))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_RECYCLE: missing 'id' parameter" }
                    return@with
                }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val inventory = svc.inventory.getInventory()
                val itemToRecycle = inventory.find { it.id == itemId }

                if (itemToRecycle == null) {
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false}""")))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_RECYCLE: item not found with id=$itemId" }
                    return@with
                }

                svc.inventory.updateInventory { items ->
                    items.filter { it.id != itemId }
                }

                val recycledItems = generateRecycleRewards(itemToRecycle.type)

                if (recycledItems.isNotEmpty()) {
                    svc.inventory.updateInventory { items ->
                        items + recycledItems
                    }
                }

                val responseJson = if (recycledItems.isNotEmpty()) {
                    val itemsJsonArray = recycledItems.joinToString(",") { item ->
                        """{"id":"${item.id}","type":"${item.type}","qty":${item.qty},"new":true}"""
                    }
                    """{"success":true,"qty":0,"items":[$itemsJsonArray]}"""
                } else {
                    """{"success":true,"qty":0}"""
                }

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                Logger.info(LogConfigSocketToClient) {
                    "Item recycled: id=$itemId, type=${itemToRecycle.type}, rewards=${recycledItems.size} items for player ${connection.playerId}"
                }
            }

            SaveDataMethod.ITEM_DISPOSE -> {
                val itemId = data["id"] as? String
                if (itemId == null) {
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false}""")))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_DISPOSE: missing 'id' parameter" }
                    return@with
                }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val inventory = svc.inventory.getInventory()
                val itemToDispose = inventory.find { it.id == itemId }

                if (itemToDispose == null) {
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false}""")))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_DISPOSE: item not found with id=$itemId" }
                    return@with
                }

                svc.inventory.updateInventory { items ->
                    items.filter { it.id != itemId }
                }

                send(PIOSerializer.serialize(buildMsg(saveId, """{"success":true,"qty":0}""")))

                Logger.info(LogConfigSocketToClient) { "Item disposed: id=$itemId, type=${itemToDispose.type}, qty=${itemToDispose.qty} for player ${connection.playerId}" }
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
