package server.handler.save.crate

import server.broadcast.BroadcastService
import core.items.ItemFactory
import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.crate.response.CrateUnlockResponse
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import utils.JSON
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

                val responseJson = JSON.encode(
                    CrateUnlockResponse(
                        success = true,
                        item = item,
                        keyId = keyId,
                        crateId = crateId,
                    )
                )

                Logger.info(LogConfigSocketToClient) { "Opening crateId=$crateId with keyId=$keyId" }

                try {
                    val playerName = connection.playerId 
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
