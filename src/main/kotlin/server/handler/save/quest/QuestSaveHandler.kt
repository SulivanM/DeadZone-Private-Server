package server.handler.save.quest

import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import utils.LogConfigSocketToClient
import utils.Logger

class QuestSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.QUEST_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.QUEST_COLLECT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'QUEST_COLLECT' message [not implemented]" }
            }

            SaveDataMethod.QUEST_TRACK -> {
                handleQuestTrack(ctx)
            }

            SaveDataMethod.QUEST_UNTRACK -> {
                handleQuestUntrack(ctx)
            }

            SaveDataMethod.QUEST_DAILY_DECLINE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'QUEST_DAILY_DECLINE' message [not implemented]" }
            }

            SaveDataMethod.QUEST_DAILY_ACCEPT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'QUEST_DAILY_ACCEPT' message [not implemented]" }
            }

            SaveDataMethod.REPEAT_ACHIEVEMENT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'REPEAT_ACHIEVEMENT' message [not implemented]" }
            }

            SaveDataMethod.GLOBAL_QUEST_COLLECT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'GLOBAL_QUEST_COLLECT' message [not implemented]" }
            }
        }
    }

    private suspend fun handleQuestTrack(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId ?: run {
            Logger.error(LogConfigSocketToClient) { "QUEST_TRACK: No playerId in connection" }
            return
        }

        val questId = data["id"] as? String ?: run {
            Logger.error(LogConfigSocketToClient) { "QUEST_TRACK: Missing quest id 'id'" }
            return
        }

        val playerObjects = serverContext.db.loadPlayerObjects(playerId) ?: run {
            Logger.error(LogConfigSocketToClient) { "QUEST_TRACK: PlayerObjects not found for playerId=$playerId" }
            return
        }

        val currentTracked = playerObjects.questsTracked?.split(",")?.filter { it.isNotBlank() }?.toMutableList() ?: mutableListOf()

        if (!currentTracked.contains(questId)) {
            currentTracked.add(questId)

            val updatedPlayerObjects = playerObjects.copy(
                questsTracked = currentTracked.joinToString(",")
            )

            serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

            Logger.info(LogConfigSocketToClient) { "QUEST_TRACK: Tracked quest $questId for player $playerId" }

            sendMessage(
                "saveOK",
                "saveID", saveId,
                "success", true
            )
        } else {
            Logger.info(LogConfigSocketToClient) { "QUEST_TRACK: Quest $questId already tracked for player $playerId" }
            sendMessage(
                "saveOK",
                "saveID", saveId,
                "success", true
            )
        }
    }

    private suspend fun handleQuestUntrack(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId ?: run {
            Logger.error(LogConfigSocketToClient) { "QUEST_UNTRACK: No playerId in connection" }
            return
        }

        val questId = data["id"] as? String ?: run {
            Logger.error(LogConfigSocketToClient) { "QUEST_UNTRACK: Missing quest id 'id'" }
            return
        }

        val playerObjects = serverContext.db.loadPlayerObjects(playerId) ?: run {
            Logger.error(LogConfigSocketToClient) { "QUEST_UNTRACK: PlayerObjects not found for playerId=$playerId" }
            return
        }

        val currentTracked = playerObjects.questsTracked?.split(",")?.filter { it.isNotBlank() }?.toMutableList() ?: mutableListOf()

        if (currentTracked.remove(questId)) {
            val updatedPlayerObjects = playerObjects.copy(
                questsTracked = if (currentTracked.isEmpty()) null else currentTracked.joinToString(",")
            )

            serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

            Logger.info(LogConfigSocketToClient) { "QUEST_UNTRACK: Untracked quest $questId for player $playerId" }

            sendMessage(
                "saveOK",
                "saveID", saveId,
                "success", true
            )
        } else {
            Logger.info(LogConfigSocketToClient) { "QUEST_UNTRACK: Quest $questId was not tracked for player $playerId" }
            sendMessage(
                "saveOK",
                "saveID", saveId,
                "success", true
            )
        }
    }
}
