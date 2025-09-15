package dev.deadzone.socket.handler.save.compound.misc

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class CmpMiscSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.COMPOUND_MISC_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        when (type) {
            SaveDataMethod.CRAFT_ITEM -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CRAFT_ITEM' message [not implemented]" }
            }

            SaveDataMethod.CRAFT_UPGRADE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CRAFT_UPGRADE' message [not implemented]" }
            }

            SaveDataMethod.CRAFT_SCHEMATIC -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CRAFT_SCHEMATIC' message [not implemented]" }
            }

            SaveDataMethod.EFFECT_SET -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'EFFECT_SET' message [not implemented]" }
            }

            SaveDataMethod.RESEARCH_START -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'RESEARCH_START' message [not implemented]" }
            }

            SaveDataMethod.AH_EVENT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'AH_EVENT' message [not implemented]" }
            }

            SaveDataMethod.CULL_NEIGHBORS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'CULL_NEIGHBORS' message [not implemented]" }
            }

            SaveDataMethod.RALLY_ASSIGNMENT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'RALLY_ASSIGNMENT' message [not implemented]" }
            }
        }
    }
}
