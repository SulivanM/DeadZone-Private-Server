package core.quests

import context.requirePlayerContext
import context.ServerContext
import core.data.GameDefinition
import core.survivor.XpLevelService
import data.collection.Inventory
import data.collection.PlayerObjects
import common.Logger
import common.LogConfigSocketToClient

/**
 * Service for handling achievement auto-completion and progress tracking
 */
object AchievementService {
    
    /**
     * Check all achievements and auto-complete any that have been achieved
     * Returns updated PlayerObjects and a map of newly completed achievement IDs to their reward data
     */
    suspend fun checkAndCompleteAchievements(
        playerObjects: PlayerObjects,
        inventory: Inventory? = null,
        serverContext: ServerContext
    ): Pair<PlayerObjects, Map<String, AchievementCompletionData>> {
        
        val completedAchievements = mutableMapOf<String, AchievementCompletionData>()
        var updatedPlayerObjects = playerObjects
        
        // Check each achievement
        for ((achievementId, achievementDef) in GameDefinition.achievementsById) {
            // Skip if already completed
            if (QuestSystem.isQuestCompleted(achievementId, updatedPlayerObjects)) {
                continue
            }
            
            // Check if prerequisites are met
            if (!QuestSystem.checkPrerequisites(achievementDef, updatedPlayerObjects)) {
                continue
            }
            
            // Check if all goals are completed
            val progress = QuestSystem.checkQuestObjectives(achievementDef, updatedPlayerObjects, inventory)
            if (progress.isCompleted) {
                // Mark achievement as complete
                updatedPlayerObjects = QuestSystem.markQuestCompleted(achievementId, updatedPlayerObjects)
                
                // Get player level for reward calculation
                val playerSurvivor = updatedPlayerObjects.survivors.find { it.id == updatedPlayerObjects.playerSurvivor }
                val playerLevel = playerSurvivor?.level ?: 1
                
                // Calculate rewards
                val rewards = QuestSystem.calculateRewards(achievementDef, playerLevel)
                
                // Apply XP rewards immediately for achievements (they don't need to be "collected")
                if (rewards.xp > 0 && playerSurvivor != null) {
                    try {
                        val playerId = updatedPlayerObjects.playerId
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
                            Logger.error(common.LogConfigSocketError) {
                                "ACHIEVEMENT: Failed to update leader XP for playerId=$playerId: ${updateResult.exceptionOrNull()?.message}"
                            }
                        }
                        
                        // Update PlayerObjects with new levelPts and consumed restXP
                        updatedPlayerObjects = updatedPlayerObjectsAfterXp
                        
                        Logger.info(LogConfigSocketToClient) {
                            "ACHIEVEMENT: Granted ${rewards.xp} XP for achievement $achievementId. " +
                            "Level: ${playerSurvivor.level}->${updatedLeader.level}, " +
                            "XP: ${playerSurvivor.xp}->${updatedLeader.xp}"
                        }
                    } catch (e: Exception) {
                        Logger.error(common.LogConfigSocketError) {
                            "ACHIEVEMENT: Failed to apply XP rewards for achievement $achievementId: ${e.message}"
                        }
                    }
                }
                
                completedAchievements[achievementId] = AchievementCompletionData(
                    achievementId = achievementId,
                    rewards = rewards
                )
                
                Logger.info { "Achievement completed: $achievementId (Level $playerLevel, XP: ${rewards.xp})" }
            }
        }
        
        return updatedPlayerObjects to completedAchievements
    }
    
    /**
     * Get progress for all non-completed achievements
     */
    fun getAchievementProgress(
        playerObjects: PlayerObjects,
        inventory: Inventory? = null
    ): Map<String, QuestProgress> {
        val result = mutableMapOf<String, QuestProgress>()
        
        for ((achievementId, achievementDef) in GameDefinition.achievementsById) {
            // Skip if already completed
            if (QuestSystem.isQuestCompleted(achievementId, playerObjects)) {
                continue
            }
            
            // Check if prerequisites are met
            if (!QuestSystem.checkPrerequisites(achievementDef, playerObjects)) {
                continue
            }
            
            // Get progress
            val progress = QuestSystem.checkQuestObjectives(achievementDef, playerObjects, inventory)
            result[achievementId] = progress
        }
        
        return result
    }
}

/**
 * Data for a newly completed achievement
 */
data class AchievementCompletionData(
    val achievementId: String,
    val rewards: QuestRewardResult
)
