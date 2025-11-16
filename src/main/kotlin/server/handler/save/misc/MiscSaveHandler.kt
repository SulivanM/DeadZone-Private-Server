package server.handler.save.misc

import context.requirePlayerContext
import core.metadata.model.PlayerFlags_Constants
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import server.service.OfferService
import common.JSON
import common.LogConfigSocketToClient
import common.Logger
import common.toJsonElement
import kotlinx.serialization.json.JsonElement
import kotlin.experimental.inv

class MiscSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.MISC_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.TUTORIAL_PVP_PRACTICE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'TUTORIAL_PVP_PRACTICE' message [not implemented]" }
            }

            SaveDataMethod.TUTORIAL_COMPLETE -> {
                val playerId = connection.playerId
                val services = serverContext.requirePlayerContext(playerId).services
                val current = services.playerObjectMetadata.getPlayerFlags()
                val bitIndex = PlayerFlags_Constants.TutorialComplete.toInt()
                val updated = setFlag(current, bitIndex, true)
                services.playerObjectMetadata.updatePlayerFlags(updated)
                Logger.info(LogConfigSocketToClient) { "Tutorial completed flag set for playerId=$playerId" }
            }

            SaveDataMethod.GET_OFFERS -> {
                handleGetOffers(ctx)
            }

            SaveDataMethod.NEWS_READ -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'NEWS_READ' message [not implemented]" }
            }

            SaveDataMethod.CLEAR_NOTIFICATIONS -> {
                val playerId = connection.playerId
                val services = serverContext.requirePlayerContext(playerId).services
                services.playerObjectMetadata.clearNotifications()
                Logger.info(LogConfigSocketToClient) { "Notifications cleared for playerId=$playerId" }
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

    private suspend fun handleGetOffers(ctx: SaveHandlerContext) = with(ctx) {
        try {
            // Get all available offers from the service
            val offers = OfferService.getOffersAsMap()

            Logger.info(LogConfigSocketToClient) { "GET_OFFERS: Returning ${offers.size} offers" }

            // Build response with success flag and offers map
            // Client expects: { "success": true, "offers": { "offer_id": { ...offer_data... }, ... } }
            val responseData = buildMap<String, Any> {
                put("success", true)
                put("offers", offers)
            }

            // Use JSON.encode() with JsonElement.serializer() for proper nested structure serialization
            val responseJson = JSON.encode(JsonElement.serializer(), responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } catch (e: Exception) {
            Logger.error(LogConfigSocketToClient) { "GET_OFFERS: Error retrieving offers: ${e.message}" }

            val responseData = mapOf(
                "success" to false,
                "errorMessage" to "Failed to retrieve offers"
            )
            val responseJson = JSON.encode(JsonElement.serializer(), responseData.toJsonElement())
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }

    private fun setFlag(flags: ByteArray, bitIndex: Int, value: Boolean): ByteArray {
        val byteIndex = bitIndex / 8
        val bitInByte = bitIndex % 8

        val arr = if (flags.size <= byteIndex) {
            flags.copyOf(byteIndex + 1)
        } else {
            flags.copyOf()
        }

        val mask = (1 shl bitInByte).toByte()
        arr[byteIndex] = if (value) {
            (arr[byteIndex].toInt() or mask.toInt()).toByte()
        } else {
            (arr[byteIndex].toInt() and mask.inv().toInt()).toByte()
        }

        return arr
    }

}
