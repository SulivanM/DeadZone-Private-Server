package server.handler.save.misc

import context.requirePlayerContext
import core.metadata.model.PlayerFlags_Constants
import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import utils.LogConfigSocketToClient
import utils.Logger
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
                Logger.warn(LogConfigSocketToClient) { "Received 'GET_OFFERS' message [not implemented]" }
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
