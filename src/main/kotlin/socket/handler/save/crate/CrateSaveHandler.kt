package dev.deadzone.socket.handler.save.crate

import dev.deadzone.context.GlobalContext
import dev.deadzone.context.ServerContext
import dev.deadzone.core.items.ItemFactory
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.buildMsg
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.handler.save.crate.response.CrateUnlockResponse
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.socket.protocol.PIOSerializer
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class CrateSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.CRATE_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        when (type) {
            SaveDataMethod.CRATE_UNLOCK -> {
                val keyId = data["keyId"] as String?
                val crateId = (data["crateId"] ?: "") as String?

                val responseJson = GlobalContext.json.encodeToString(
                    CrateUnlockResponse(
                        success = true,
                        item = ItemFactory.getRandomItem(),
                        keyId = keyId,
                        crateId = crateId,
                    )
                )

                Logger.info(LogConfigSocketToClient) { "Opening crateId=$crateId with keyId=$keyId" }

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.CRATE_MYSTERY_UNLOCK -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CRATE_MYSTERY_UNLOCK' message [not implemented]" }
            }
        }
    }
}