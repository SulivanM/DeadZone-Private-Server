package server.handler

import context.ServerContext
import core.quests.AchievementService
import core.quests.QuestSystem
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer

/**
 * Handle `qp` message by:
 *
 * 1. Sending quest progress JSON
 *
 */
class QuestProgressHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.getString(NetworkMessage.QUEST_PROGRESS) != null
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "QUEST_PROGRESS: No playerId in connection" }
            val emptyMessage = listOf(NetworkMessage.QUEST_PROGRESS, """{"complete": null, "progress": null}""")
            send(PIOSerializer.serialize(emptyMessage))
            return
        }

        // Load player data
        val initialPlayerObjects = serverContext.db.loadPlayerObjects(playerId)
        if (initialPlayerObjects == null) {
            Logger.warn(LogConfigSocketToClient) { "QUEST_PROGRESS: PlayerObjects not found for playerId=$playerId" }
            val emptyMessage = listOf(NetworkMessage.QUEST_PROGRESS, """{"complete": null, "progress": null}""")
            send(PIOSerializer.serialize(emptyMessage))
            return
        }

        // Load inventory for ITEM goal tracking only if needed
        // Check if any quest/achievement has ITEM goals to avoid unnecessary DB query
        val hasItemGoals = core.data.GameDefinition.questsById.values.any { quest ->
            quest.goals.any { it.type == core.data.resources.GoalType.ITEM }
        } || core.data.GameDefinition.achievementsById.values.any { achievement ->
            achievement.goals.any { it.type == core.data.resources.GoalType.ITEM }
        }
        val inventory = if (hasItemGoals) serverContext.db.loadInventory(playerId) else null

        // Auto-complete achievements that have met their goals
        val (playerObjectsAfterAchievements, newlyCompletedAchievements) = AchievementService.checkAndCompleteAchievements(
            initialPlayerObjects,
            inventory,
            serverContext
        )
        
        // Save updated player objects if achievements were completed
        if (newlyCompletedAchievements.isNotEmpty()) {
            serverContext.db.updatePlayerObjectsJson(playerId, playerObjectsAfterAchievements)
            Logger.info(LogConfigSocketToClient) { 
                "QUEST_PROGRESS: Auto-completed ${newlyCompletedAchievements.size} achievements for player $playerId: ${newlyCompletedAchievements.keys}" 
            }
        }

        // Auto-complete quests that have met their goals
        var playerObjects = playerObjectsAfterAchievements
        var questsCompleted = false
        for ((questId, questDef) in core.data.GameDefinition.questsById) {
            // Skip if already completed
            if (QuestSystem.isQuestCompleted(questId, playerObjects)) {
                continue
            }
            
            // Check if prerequisites are met
            if (!QuestSystem.checkPrerequisites(questDef, playerObjects)) {
                continue
            }
            
            // Check if all goals are completed
            val progress = QuestSystem.checkQuestObjectives(questDef, playerObjects, inventory)
            if (progress.isCompleted) {
                // Mark quest as complete
                playerObjects = QuestSystem.markQuestCompleted(questId, playerObjects)
                questsCompleted = true
                Logger.info(LogConfigSocketToClient) { "QUEST_PROGRESS: Auto-completed quest $questId for player $playerId" }
            }
        }
        
        // Save if quests were completed
        val finalPlayerObjects = if (questsCompleted) {
            serverContext.db.updatePlayerObjectsJson(playerId, playerObjects)
            playerObjects
        } else {
            playerObjects
        }

        // Build completion map with reward data for newly completed achievements
        // Client expects: { "achievementId": { xp: 100, res: {...}, items: [...] } }
        val completedMap = mutableMapOf<String, RewardData?>()
        
        // Add newly completed achievements with their reward data
        for ((achievementId, completionData) in newlyCompletedAchievements) {
            val xp = if (completionData.rewards.xp > 0) completionData.rewards.xp else null
            
            // Add resources if any
            val resources = mutableMapOf<String, Int>()
            for (item in completionData.rewards.items) {
                if (item.type == core.quests.RewardItemType.RESOURCE) {
                    resources[item.id] = item.quantity
                }
            }
            
            // Add items if any
            val items = completionData.rewards.items.filter { it.type == core.quests.RewardItemType.ITEM }
            val itemsList = if (items.isNotEmpty()) {
                items.map { ItemReward(id = it.id, qty = it.quantity) }
            } else null
            
            completedMap[achievementId] = if (xp != null || resources.isNotEmpty() || itemsList != null) {
                RewardData(
                    xp = xp,
                    res = if (resources.isNotEmpty()) resources else null,
                    items = itemsList
                )
            } else null
        }
        
        // Add all other completed quests/achievements (without reward data since they were completed before)
        for ((questId, _) in core.data.GameDefinition.questsById) {
            if (QuestSystem.isQuestCompleted(questId, finalPlayerObjects) && !completedMap.containsKey(questId)) {
                completedMap[questId] = null
            }
        }
        
        for ((achievementId, _) in core.data.GameDefinition.achievementsById) {
            if (QuestSystem.isQuestCompleted(achievementId, finalPlayerObjects) && !completedMap.containsKey(achievementId)) {
                completedMap[achievementId] = null
            }
        }

        // Get quest progress
        val questProgressMap = mutableMapOf<String, Map<String, Int>>()
        val availableQuests = QuestSystem.getAvailableQuestsWithProgress(finalPlayerObjects, inventory)

        for ((questId, progress) in availableQuests) {
            if (!progress.isCompleted) {
                // Convert objectives map to indexed map (0, 1, 2, ...) with just current values
                // Client expects: { "questId": { "0": currentValue, "1": currentValue, ... } }
                val objectivesData = progress.objectives.entries.mapIndexed { index, (_, objProgress) ->
                    index.toString() to objProgress.current
                }.toMap()
                questProgressMap[questId] = objectivesData
            }
        }
        
        // Get achievement progress
        val achievementProgress = AchievementService.getAchievementProgress(finalPlayerObjects, inventory)
        for ((achievementId, progress) in achievementProgress) {
            if (!progress.isCompleted) {
                // Convert objectives map to indexed map
                val objectivesData = progress.objectives.entries.mapIndexed { index, (_, objProgress) ->
                    index.toString() to objProgress.current
                }.toMap()
                questProgressMap[achievementId] = objectivesData
            }
        }

        // Build response
        val response = QuestProgressResponse(
            complete = if (completedMap.isEmpty()) null else completedMap,
            progress = if (questProgressMap.isEmpty()) null else questProgressMap
        )

        val json = Json.encodeToString(response)
        val message = listOf(NetworkMessage.QUEST_PROGRESS, json)
        send(PIOSerializer.serialize(message))

        Logger.debug(LogConfigSocketToClient) { "QUEST_PROGRESS: Sent progress for player $playerId - ${completedMap.size} completed, ${questProgressMap.size} in progress" }
    }
}

@Serializable
data class QuestProgressResponse(
    val complete: Map<String, RewardData?>?,
    // Map of quest ID to objectives map (objective index to current progress value)
    // e.g., { "storageQuest": { "0": 1, "1": 0, "2": 2 } }
    val progress: Map<String, Map<String, Int>>?
)

@Serializable
data class RewardData(
    val xp: Int? = null,
    val res: Map<String, Int>? = null,
    val items: List<ItemReward>? = null
)

@Serializable
data class ItemReward(
    val id: String,
    val qty: Int
)


