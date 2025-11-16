package server.handler.save.quest

import context.requirePlayerContext
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import common.JSON
import common.LogConfigSocketToClient
import common.Logger
import common.LogConfigSocketError
import core.survivor.XpLevelService

class QuestSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.QUEST_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.QUEST_COLLECT -> {
                handleQuestCollect(ctx)
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

            val responseData = mapOf("success" to true)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } else {
            Logger.info(LogConfigSocketToClient) { "QUEST_TRACK: Quest $questId already tracked for player $playerId" }
            val responseData = mapOf("success" to true)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
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

            val responseData = mapOf("success" to true)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        } else {
            Logger.info(LogConfigSocketToClient) { "QUEST_UNTRACK: Quest $questId was not tracked for player $playerId" }
            val responseData = mapOf("success" to true)
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
        }
    }

    private suspend fun handleQuestCollect(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId ?: run {
            Logger.error(LogConfigSocketToClient) { "QUEST_COLLECT: No playerId in connection" }
            return
        }

        val questId = data["id"] as? String ?: run {
            Logger.error(LogConfigSocketToClient) { "QUEST_COLLECT: Missing quest id 'id'" }
            return
        }

        val playerObjects = serverContext.db.loadPlayerObjects(playerId) ?: run {
            Logger.error(LogConfigSocketToClient) { "QUEST_COLLECT: PlayerObjects not found for playerId=$playerId" }
            return
        }

        // Find the quest definition
        val questDef = core.data.GameDefinition.findQuestOrAchievement(questId)
        if (questDef == null) {
            Logger.error(LogConfigSocketToClient) { "QUEST_COLLECT: Quest not found: $questId" }
            val responseData = mapOf(
                "success" to false,
                "error" to "Quest not found"
            )
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return
        }

        // Check quest objectives and auto-complete if all objectives are met
        var updatedPlayerObjects = playerObjects
        if (!core.quests.QuestSystem.isQuestCompleted(questId, playerObjects)) {
            // Check if objectives are completed
            val progress = core.quests.QuestSystem.checkQuestObjectives(questDef, playerObjects)
            if (progress.isCompleted) {
                // Auto-complete the quest
                updatedPlayerObjects = core.quests.QuestSystem.markQuestCompleted(questId, updatedPlayerObjects)
                Logger.info(LogConfigSocketToClient) { "QUEST_COLLECT: Auto-completed quest $questId for player $playerId" }
            } else {
                Logger.warn(LogConfigSocketToClient) { "QUEST_COLLECT: Quest $questId not completed for player $playerId" }
                val responseData = mapOf(
                    "success" to false,
                    "error" to "Quest not completed"
                )
                val responseJson = JSON.encode(responseData)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                return
            }
        }

        // Check if already collected
        if (core.quests.QuestSystem.isQuestCollected(questId, updatedPlayerObjects)) {
            Logger.warn(LogConfigSocketToClient) { "QUEST_COLLECT: Quest $questId already collected for player $playerId" }
            val responseData = mapOf(
                "success" to false,
                "error" to "Quest already collected"
            )
            val responseJson = JSON.encode(responseData)
            send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            return
        }

        // Get player level
        val playerSurvivor = updatedPlayerObjects.survivors.find { it.id == updatedPlayerObjects.playerSurvivor }
        val playerLevel = playerSurvivor?.level ?: 1

        // Calculate rewards
        val rewards = core.quests.QuestSystem.calculateRewards(questDef, playerLevel)

        // Apply XP rewards using centralized service (CRITICAL FIX)
        if (rewards.xp > 0 && playerSurvivor != null) {
            try {
                val svc = serverContext.requirePlayerContext(playerId).services

                // Use centralized XP service to add XP with rested bonus and level calculation
                val (updatedLeader, updatedPlayerObjectsAfterXp) = XpLevelService.addXpToLeader(
                    survivor = playerSurvivor,
                    playerObjects = updatedPlayerObjects,
                    earnedXp = rewards.xp
                )

                // Update survivor in database via SurvivorService for proper persistence
                val updateResult = svc.survivor.updateSurvivor(playerSurvivor.id) { _ ->
                    updatedLeader
                }
                if (updateResult.isFailure) {
                    Logger.error(LogConfigSocketError) {
                        "QUEST_COLLECT: Failed to update leader XP for playerId=$playerId: ${updateResult.exceptionOrNull()?.message}"
                    }
                }

                // Update PlayerObjects with new levelPts and consumed restXP
                updatedPlayerObjects = updatedPlayerObjectsAfterXp

                Logger.info(LogConfigSocketToClient) {
                    "QUEST_COLLECT: Added ${rewards.xp} XP to leader. " +
                    "Level: ${playerSurvivor.level}->${updatedLeader.level}, " +
                    "XP: ${playerSurvivor.xp}->${updatedLeader.xp}, " +
                    "LevelPts: ${updatedPlayerObjects.levelPts}"
                }
            } catch (e: Exception) {
                Logger.error(LogConfigSocketError) {
                    "QUEST_COLLECT: Failed to apply XP rewards for playerId=$playerId: ${e.message}"
                }
            }
        }

        // Add resources
        var updatedResources = updatedPlayerObjects.resources
        for (item in rewards.items) {
            when (item.type) {
                core.quests.RewardItemType.RESOURCE -> {
                    when (item.id) {
                        "wood" -> updatedResources = updatedResources.copy(wood = updatedResources.wood + item.quantity)
                        "metal" -> updatedResources = updatedResources.copy(metal = updatedResources.metal + item.quantity)
                        "cloth" -> updatedResources = updatedResources.copy(cloth = updatedResources.cloth + item.quantity)
                        "food" -> updatedResources = updatedResources.copy(food = updatedResources.food + item.quantity)
                        "water" -> updatedResources = updatedResources.copy(water = updatedResources.water + item.quantity)
                        "ammunition" -> updatedResources = updatedResources.copy(ammunition = updatedResources.ammunition + item.quantity)
                        "cash" -> updatedResources = updatedResources.copy(cash = updatedResources.cash + item.quantity)
                    }
                }
                core.quests.RewardItemType.ITEM -> {
                    // Add item to inventory
                    try {
                        val services = serverContext.requirePlayerContext(playerId).services
                        val newItem = core.items.model.Item(
                            id = "${item.id}_${System.currentTimeMillis()}", // Generate unique ID
                            type = item.id,
                            qty = item.quantity.toUInt(),
                            specData = null,
                            new = true
                        )
                        services.inventory.updateInventory { items ->
                            items + newItem
                        }
                        Logger.info(LogConfigSocketToClient) { "QUEST_COLLECT: Added item ${item.id} x${item.quantity} to inventory for player $playerId" }
                    } catch (e: Exception) {
                        Logger.error(LogConfigSocketToClient) { "QUEST_COLLECT: Failed to add item ${item.id}: ${e.message}" }
                    }
                }
            }
        }
        updatedPlayerObjects = updatedPlayerObjects.copy(resources = updatedResources)

        // Mark quest as collected
        updatedPlayerObjects = core.quests.QuestSystem.markQuestCollected(questId, updatedPlayerObjects)

        // Save updated player data
        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

        Logger.info(LogConfigSocketToClient) { "QUEST_COLLECT: Collected quest $questId for player $playerId. XP: ${rewards.xp}, Items: ${rewards.items.size}" }

        val responseData = mapOf(
            "success" to true,
            "xp" to rewards.xp,
            "levelPts" to updatedPlayerObjects.levelPts
        )
        val responseJson = JSON.encode(responseData)
        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
    }
}
