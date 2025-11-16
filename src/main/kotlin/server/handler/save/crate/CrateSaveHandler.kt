package server.handler.save.crate

import server.broadcast.BroadcastService
import core.items.ItemFactory
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.crate.response.CrateUnlockResponse
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import common.JSON
import common.LogConfigSocketToClient
import common.Logger

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

                // Broadcast item unboxed
                try {
                    val playerProfile = serverContext.playerAccountRepository.getProfileOfPlayerId(connection.playerId).getOrNull()
                    val playerName = playerProfile?.displayName ?: connection.playerId
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