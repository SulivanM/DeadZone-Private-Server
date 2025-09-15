package dev.deadzone.socket.handler.save.purchase

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class PurchaseSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.PURCHASE_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        when (type) {
            SaveDataMethod.RESOURCE_BUY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'RESOURCE_BUY' message [not implemented]" }
            }

            SaveDataMethod.PROTECTION_BUY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'PROTECTION_BUY' message [not implemented]" }
            }

            SaveDataMethod.PAYVAULT_BUY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'PAYVAULT_BUY' message [not implemented]" }
            }

            SaveDataMethod.CLAIM_PROMO_CODE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CLAIM_PROMO_CODE' message [not implemented]" }
            }

            SaveDataMethod.BUY_PACKAGE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BUY_PACKAGE' message [not implemented]" }
            }

            SaveDataMethod.CHECK_APPLY_DIRECT_PURCHASE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CHECK_APPLY_DIRECT_PURCHASE' message [not implemented]" }
            }

            SaveDataMethod.HAS_PAYVAULT_ITEM -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'HAS_PAYVAULT_ITEM' message [not implemented]" }
            }

            SaveDataMethod.INCREMENT_PURCHASE_COUNT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'INCREMENT_PURCHASE_COUNT' message [not implemented]" }
            }

            SaveDataMethod.DEATH_MOBILE_RENAME -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'DEATH_MOBILE_RENAME' message [not implemented]" }
            }
        }
    }
}
