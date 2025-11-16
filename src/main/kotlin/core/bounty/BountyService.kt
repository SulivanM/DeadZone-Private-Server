package core.bounty

import common.Logger
import common.LogConfigSocketToClient
import core.items.ItemFactory
import core.items.model.Item
import core.model.game.data.bounty.InfectedBounty
import core.model.game.data.bounty.InfectedBountyTask
import core.model.game.data.bounty.InfectedBountyTaskCondition
import data.collection.PlayerObjects
import kotlin.random.Random

/**
 * Service for managing infected bounty progression and completion
 */
class BountyService {

    /**
     * Result of bounty update containing what changed
     */
    data class BountyUpdateResult(
        val updatedBounty: InfectedBounty,
        val completedConditions: List<ConditionCompletion> = emptyList(),
        val completedTasks: List<TaskCompletion> = emptyList(),
        val bountyCompleted: BountyCompletion? = null
    )

    data class ConditionCompletion(
        val taskIndex: Int,
        val conditionIndex: Int,
        val condition: InfectedBountyTaskCondition
    )

    data class TaskCompletion(
        val taskIndex: Int,
        val task: InfectedBountyTask
    )

    data class BountyCompletion(
        val bounty: InfectedBounty,
        val rewardItem: Item
    )

    /**
     * Update bounty progress based on kills from a mission
     * @param bounty Current bounty
     * @param killData Map of zombie type to kill count from mission
     * @param suburb Suburb where the mission took place
     * @return BountyUpdateResult with updated bounty and completion info
     */
    fun updateBountyProgress(
        bounty: InfectedBounty,
        killData: Map<String, Int>,
        suburb: String
    ): BountyUpdateResult? {
        if (bounty.completed || bounty.abandoned) {
            Logger.info(LogConfigSocketToClient) {
                "Bounty ${bounty.id} is already ${if (bounty.completed) "completed" else "abandoned"}, skipping update"
            }
            return null
        }

        // Find the task for this suburb
        val taskIndex = bounty.tasks.indexOfFirst { it.suburb == suburb }
        if (taskIndex == -1) {
            Logger.info(LogConfigSocketToClient) {
                "No bounty task found for suburb: $suburb"
            }
            return null
        }

        val task = bounty.tasks[taskIndex]
        if (task.completed) {
            Logger.info(LogConfigSocketToClient) {
                "Task for suburb $suburb is already completed"
            }
            return null
        }

        val completedConditions = mutableListOf<ConditionCompletion>()
        val completedTasks = mutableListOf<TaskCompletion>()

        // Update conditions with new kills
        val updatedConditions = task.conditions.mapIndexed { conditionIndex, condition ->
            if (condition.isComplete) {
                condition
            } else {
                val zombieType = condition.zombieType
                val killsFromMission = killData[zombieType] ?: 0

                if (killsFromMission > 0) {
                    val newKills = (condition.kills + killsFromMission).coerceAtMost(condition.killsRequired)
                    val wasComplete = condition.isComplete
                    val updatedCondition = condition.copy(kills = newKills)

                    // Check if condition just became complete
                    if (!wasComplete && updatedCondition.isComplete) {
                        completedConditions.add(
                            ConditionCompletion(taskIndex, conditionIndex, updatedCondition)
                        )
                        Logger.info(LogConfigSocketToClient) {
                            "Bounty condition completed: ${condition.zombieType} ${updatedCondition.kills}/${updatedCondition.killsRequired}"
                        }
                    }

                    updatedCondition
                } else {
                    condition
                }
            }
        }

        // Check if all conditions in task are now complete
        val allConditionsComplete = updatedConditions.all { it.isComplete }
        val updatedTask = task.copy(
            conditions = updatedConditions,
            completed = allConditionsComplete
        )

        // Track if task just became complete
        if (!task.completed && updatedTask.completed) {
            completedTasks.add(TaskCompletion(taskIndex, updatedTask))
            Logger.info(LogConfigSocketToClient) {
                "Bounty task completed for suburb: ${updatedTask.suburb}"
            }
        }

        // Update the bounty with the modified task
        val updatedTasks = bounty.tasks.toMutableList()
        updatedTasks[taskIndex] = updatedTask

        // Check if all tasks are complete
        val allTasksComplete = updatedTasks.all { it.completed }

        var bountyCompletion: BountyCompletion? = null
        var updatedBounty = bounty.copy(
            tasks = updatedTasks,
            completed = allTasksComplete
        )

        // If bounty just completed, generate reward
        if (!bounty.completed && updatedBounty.completed) {
            val rewardItem = generateBountyReward()
            updatedBounty = updatedBounty.copy(rewardItemId = rewardItem.id)
            bountyCompletion = BountyCompletion(updatedBounty, rewardItem)
            Logger.info(LogConfigSocketToClient) {
                "Bounty ${updatedBounty.id} completed! Reward: ${rewardItem.id}"
            }
        }

        return BountyUpdateResult(
            updatedBounty = updatedBounty,
            completedConditions = completedConditions,
            completedTasks = completedTasks,
            bountyCompleted = bountyCompletion
        )
    }

    /**
     * Generate a reward item for completing a bounty
     */
    private fun generateBountyReward(): Item {
        // Define possible reward items with their weights
        val rewardPool = listOf(
            "weapon-rifle-assault-ak47" to 5,
            "weapon-rifle-sniper-m40" to 5,
            "weapon-shotgun-benelli" to 5,
            "weapon-pistol-desert-eagle" to 8,
            "gear-helmet-combat" to 10,
            "gear-vest-kevlar" to 10,
            "gear-boots-tactical" to 10,
            "medical-medkit" to 15,
            "fuel-container" to 20,
            "ammo-box" to 12
        )

        // Weighted random selection
        val totalWeight = rewardPool.sumOf { it.second }
        var randomValue = Random.nextInt(totalWeight)

        var selectedItemType = rewardPool.first().first
        for ((itemType, weight) in rewardPool) {
            randomValue -= weight
            if (randomValue < 0) {
                selectedItemType = itemType
                break
            }
        }

        // Generate the item using ItemFactory
        return ItemFactory.createItemFromId(idInXML = selectedItemType)
    }

    /**
     * Check if bounty exists and is active for a player
     */
    fun hasActiveBounty(playerObjects: PlayerObjects?): Boolean {
        if (playerObjects == null || playerObjects.dzBounty == null) {
            return false
        }
        val bounty = playerObjects.dzBounty
        return !bounty.completed && !bounty.abandoned
    }

    /**
     * Get the suburb name from area type
     * Maps game area types to bounty suburb names
     */
    fun getSuburbFromAreaType(areaType: String): String? {
        return when {
            areaType.contains("dartside", ignoreCase = true) -> "Dartside"
            areaType.contains("doddington", ignoreCase = true) -> "Doddingston"
            areaType.contains("greyside_nw", ignoreCase = true) -> "Greyside_NW"
            areaType.contains("greyside_ne", ignoreCase = true) -> "Greyside_NE"
            areaType.contains("greyside_sw", ignoreCase = true) -> "Greyside_SW"
            areaType.contains("greyside_se", ignoreCase = true) -> "Greyside_SE"
            areaType.contains("nastya", ignoreCase = true) -> "Nastya's Holdout"
            areaType.contains("secronom", ignoreCase = true) -> "Secronom"
            areaType.contains("wasteland", ignoreCase = true) -> "Wasteland"
            else -> null
        }
    }
}
