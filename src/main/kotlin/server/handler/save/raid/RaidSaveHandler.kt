package server.handler.save.raid

import server.handler.save.SaveHandlerContext
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import common.LogConfigSocketToClient
import common.Logger

class RaidSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.RAID_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
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
