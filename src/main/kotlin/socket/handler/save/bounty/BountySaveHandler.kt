package socket.handler.save.bounty

import dev.deadzone.socket.handler.save.SaveHandlerContext
import socket.handler.save.SaveSubHandler
import socket.messaging.SaveDataMethod
import utils.LogConfigSocketToClient
import utils.Logger

class BountySaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.BOUNTY_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.BOUNTY_VIEW -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_VIEW' message [not implemented]" }
            }

            SaveDataMethod.BOUNTY_SPEED_UP -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_SPEED_UP' message [not implemented]" }
            }

            SaveDataMethod.BOUNTY_NEW -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_NEW' message [not implemented]" }
            }

            SaveDataMethod.BOUNTY_ABANDON -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_ABANDON' message [not implemented]" }
            }

            SaveDataMethod.BOUNTY_ADD -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BOUNTY_ADD' message [not implemented]" }
            }
        }
    }
}
