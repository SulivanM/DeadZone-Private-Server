package dev.deadzone.socket.handler.save.raid

import dev.deadzone.context.ServerContext
import socket.core.Connection
import dev.deadzone.socket.handler.save.SaveSubHandler
import socket.messaging.SaveDataMethod
import utils.LogConfigSocketToClient
import utils.Logger

class RaidSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.RAID_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        when (type) {
            SaveDataMethod.RAID_START -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'RAID_START' message [not implemented]" }
            }

            SaveDataMethod.RAID_CONTINUE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'RAID_CONTINUE' message [not implemented]" }
            }

            SaveDataMethod.RAID_ABORT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'RAID_ABORT' message [not implemented]" }
            }

            SaveDataMethod.RAID_DEATH -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'RAID_DEATH' message [not implemented]" }
            }
        }
    }
}
