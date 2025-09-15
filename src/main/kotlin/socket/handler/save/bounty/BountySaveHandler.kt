package dev.deadzone.socket.handler.save.bounty

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class BountySaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.BOUNTY_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
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
