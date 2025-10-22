package socket.handler.save.crate

import broadcast.BroadcastService
import context.GlobalContext
import core.items.ItemFactory
import dev.deadzone.socket.handler.save.SaveHandlerContext
import socket.handler.buildMsg
import socket.handler.save.SaveSubHandler
import socket.handler.save.crate.response.CrateUnlockResponse
import socket.messaging.SaveDataMethod
import socket.protocol.PIOSerializer
import utils.LogConfigSocketToClient
import utils.Logger

class CrateSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.CRATE_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.CRATE_UNLOCK -> {
                val keyId = data["keyId"] as String?
                val crateId = (data["crateId"] ?: "") as String?

                val item = ItemFactory.getRandomItem()

                val responseJson = GlobalContext.json.encodeToString(
                    CrateUnlockResponse(
                        success = true,
                        item = item,
                        keyId = keyId,
                        crateId = crateId,
                    )
                )

                Logger.info(LogConfigSocketToClient) { "Opening crateId=$crateId with keyId=$keyId" }

                // Broadcast item unboxed
                try {
                    val playerName = connection.playerId // You might want to get the actual player name
                    val itemName = item.name ?: "Unknown Item"
                    val quality = item.quality?.toString() ?: ""

                    BroadcastService.broadcastItemUnboxed(playerName, itemName, quality)
                } catch (e: Exception) {
                    Logger.warn("Failed to broadcast item unboxed: ${e.message}")
                }

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.CRATE_MYSTERY_UNLOCK -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CRATE_MYSTERY_UNLOCK' message [not implemented]" }
            }
        }
    }
}