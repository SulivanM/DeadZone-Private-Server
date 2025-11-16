package core.quests

import core.data.GameDefinition
import core.data.resources.GoalType
import core.data.resources.QuestDefinition
import core.data.resources.QuestGoal
import core.data.resources.QuestReward
import core.data.resources.RewardType
import data.collection.PlayerObjects
import core.model.game.data.GameResources
import core.model.game.data.MissionStats
import core.model.game.data.type
import common.Logger

/**
 * Quest system service for managing quest logic
 */
object QuestSystem {

    /**
     * Check if prerequisites for a quest are met
     */
    fun checkPrerequisites(questDef: QuestDefinition, playerObjects: PlayerObjects): Boolean {
        if (questDef.prerequisites.isEmpty()) {
            return true
        }

        val questsCompleted = parseQuestCompletionStatus(playerObjects.quests)

        for (prereq in questDef.prerequisites) {
            // At least one quest in the prereq group must be completed
            var oneCompleted = false
            for (questId in prereq.questIds) {
                val prereqQuest = GameDefinition.findQuestOrAchievement(questId)
                if (prereqQuest != null) {
                    val questIndex = getQuestIndex(questId)
                    if (questIndex >= 0 && questIndex < questsCompleted.size && questsCompleted[questIndex]) {
                        oneCompleted = true
                        break
                    }
                }
            }

            if (!oneCompleted) {
                return false
            }
        }

        return true
    }

    /**
     * Check if a quest is completed
     */
    fun isQuestCompleted(questId: String, playerObjects: PlayerObjects): Boolean {
        val questIndex = getQuestIndex(questId)
        if (questIndex < 0) return false

        val questsCompleted = parseQuestCompletionStatus(playerObjects.quests)
        return questIndex < questsCompleted.size && questsCompleted[questIndex]
    }

    /**
     * Check if quest rewards have been collected
     */
    fun isQuestCollected(questId: String, playerObjects: PlayerObjects): Boolean {
        val questIndex = getQuestIndex(questId)
        if (questIndex < 0) return false

        val questsCollected = parseQuestCompletionStatus(playerObjects.questsCollected)
        return questIndex < questsCollected.size && questsCollected[questIndex]
    }

    /**
     * Mark a quest as completed
     */
    fun markQuestCompleted(questId: String, playerObjects: PlayerObjects): PlayerObjects {
        val questIndex = getQuestIndex(questId)
        if (questIndex < 0) return playerObjects

        val completed = parseQuestCompletionStatus(playerObjects.quests).toMutableList()

        // Ensure the list is large enough
        while (completed.size <= questIndex) {
            completed.add(false)
        }

        completed[questIndex] = true

        return playerObjects.copy(
            quests = booleanListToByteArray(completed)
        )
    }

    /**
     * Mark a quest as collected
     */
    fun markQuestCollected(questId: String, playerObjects: PlayerObjects): PlayerObjects {
        val questIndex = getQuestIndex(questId)
        if (questIndex < 0) return playerObjects

        val collected = parseQuestCompletionStatus(playerObjects.questsCollected).toMutableList()

        // Ensure the list is large enough
        while (collected.size <= questIndex) {
            collected.add(false)
        }

        collected[questIndex] = true

        return playerObjects.copy(
            questsCollected = booleanListToByteArray(collected)
        )
    }

    /**
     * Calculate rewards for a quest based on player level
     */
    fun calculateRewards(questDef: QuestDefinition, playerLevel: Int): QuestRewardResult {
        val rewards = mutableListOf<RewardItem>()
        var totalXP = 0

        for (reward in questDef.rewards) {
            // Check level restrictions
            if (reward.minLevel != null && playerLevel < reward.minLevel) continue
            if (reward.maxLevel != null && playerLevel > reward.maxLevel) continue

            when (reward.type) {
                RewardType.XP -> {
                    totalXP += reward.value
                }
                RewardType.XP_PERC -> {
                    // Calculate XP percentage based on player level
                    val xpForLevel = calculateXPForLevel(playerLevel - 1)
                    val xpReward = (xpForLevel * (reward.percentage ?: 0.0)).toInt()
                    val roundedXP = (xpReward / 10) * 10 // Round to nearest 10
                    totalXP += maxOf(roundedXP, 10)
                }
                RewardType.ITEM -> {
                    if (reward.id != null) {
                        rewards.add(RewardItem(RewardItemType.ITEM, reward.id, 1))
                    }
                }
                RewardType.RESOURCE -> {
                    if (reward.id != null) {
                        rewards.add(RewardItem(RewardItemType.RESOURCE, reward.id, reward.value))
                    }
                }
            }
        }

        return QuestRewardResult(totalXP, rewards)
    }

    /**
     * Calculate XP required for a level
     */
    fun calculateXPForLevel(level: Int): Int {
        // Constants from client code
        val baseXPMultiplier = 1.0 // BASE_XP_MULTIPLIER
        val levelXPMultiplier = 100.0 // LEVEL_XP_MULTIPLIER

        return (levelXPMultiplier * level * level * baseXPMultiplier).toInt()
    }

    /**
     * Check if all objectives for a quest are completed
     * Returns a map of quest IDs to their current progress (value/target)
     */
    fun checkQuestObjectives(
        questDef: QuestDefinition,
        playerObjects: PlayerObjects,
        inventory: data.collection.Inventory? = null
    ): QuestProgress {
        if (questDef.goals.isEmpty()) {
            return QuestProgress(questDef.id, true, emptyMap())
        }

        val progress = mutableMapOf<String, ObjectiveProgress>()
        var allCompleted = true

        for ((index, goal) in questDef.goals.withIndex()) {
            // Use the goal ID if available, otherwise use index
            // This ensures consistent ordering when sent to client
            val objectiveId = goal.id ?: index.toString()
            val currentValue = getCurrentValueForGoal(goal, playerObjects, inventory)
            val targetValue = goal.value
            val isCompleted = currentValue >= targetValue

            progress[objectiveId] = ObjectiveProgress(currentValue, targetValue, isCompleted)

            if (!isCompleted) {
                allCompleted = false
            }
        }

        return QuestProgress(questDef.id, allCompleted, progress)
    }

    /**
     * Get current value for a quest goal based on player data
     */
    private fun getCurrentValueForGoal(
        goal: QuestGoal,
        playerObjects: PlayerObjects,
        inventory: data.collection.Inventory? = null
    ): Int {
        return when (goal.type) {
            GoalType.LEVEL -> {
                // Get player survivor level
                val playerSurvivor = playerObjects.survivors.find { it.id == playerObjects.playerSurvivor }
                playerSurvivor?.level ?: 1
            }
            GoalType.BUILDING -> {
                // Count buildings of specific type
                val buildingId = goal.id ?: return 0
                playerObjects.buildings.count { it.type == buildingId }
            }
            GoalType.SURVIVOR -> {
                // Count survivors of specific class
                val classId = goal.id ?: return 0
                playerObjects.survivors.count { it.classId == classId }
            }
            GoalType.RESOURCE -> {
                // Get resource amount
                val resourceId = goal.id ?: return 0
                when (resourceId.lowercase()) {
                    "wood" -> playerObjects.resources.wood
                    "metal" -> playerObjects.resources.metal
                    "cloth" -> playerObjects.resources.cloth
                    "food" -> playerObjects.resources.food
                    "water" -> playerObjects.resources.water
                    "ammunition" -> playerObjects.resources.ammunition
                    "cash" -> playerObjects.resources.cash
                    else -> 0
                }
            }
            GoalType.TUTORIAL -> {
                // Check if tutorial has been completed using player flags
                // Tutorial complete flag is at index 2 (PlayerFlags_Constants.TutorialComplete)
                val flags = playerObjects.flags ?: return 0
                val tutorialCompleteIndex = 2
                if (tutorialCompleteIndex / 8 < flags.size) {
                    val byteIndex = tutorialCompleteIndex / 8
                    val bitIndex = tutorialCompleteIndex % 8
                    val isComplete = (flags[byteIndex].toInt() and (1 shl bitIndex)) != 0
                    if (isComplete) 1 else 0
                } else {
                    0
                }
            }
            GoalType.STAT -> {
                // Get stat value from lifetime stats
                val stats = playerObjects.lifetimeStats ?: return 0
                val statId = goal.id ?: return 0

                // Map stat IDs to their values in MissionStats
                when (statId.lowercase()) {
                    "zombiekills" -> stats.zombieKills
                    "zombiespawned" -> stats.zombieSpawned
                    "levelups" -> stats.levelUps
                    "damageoutput" -> stats.damageOutput.toInt()
                    "damagetaken" -> stats.damageTaken.toInt()
                    "containerssearched" -> stats.containersSearched
                    "survivorkills" -> stats.survivorKills
                    "survivorsdowned" -> stats.survivorsDowned
                    "survivorexplosivekills" -> stats.survivorExplosiveKills
                    "humankills" -> stats.humanKills
                    "humanexplosivekills" -> stats.humanExplosiveKills
                    "zombieexplosivekills" -> stats.zombieExplosiveKills
                    "hphealed" -> stats.hpHealed
                    "explosivesplaced" -> stats.explosivesPlaced
                    "grenadesthrown" -> stats.grenadesThrown
                    "grenadessmokethrown" -> stats.grenadesSmokeThrown
                    "allianceflagcaptured" -> stats.allianceFlagCaptured
                    "buildingsdestroyed" -> stats.buildingsDestroyed
                    "buildingslost" -> stats.buildingsLost
                    "buildingsexplosivedestroyed" -> stats.buildingsExplosiveDestroyed
                    "trapstriggered" -> stats.trapsTriggered
                    "trapdisarmtriggered" -> stats.trapDisarmTriggered
                    "cashfound" -> stats.cashFound
                    "woodfound" -> stats.woodFound
                    "metalfound" -> stats.metalFound
                    "clothfound" -> stats.clothFound
                    "foodfound" -> stats.foodFound
                    "waterfound" -> stats.waterFound
                    "ammunitionfound" -> stats.ammunitionFound
                    "ammunitionused" -> stats.ammunitionUsed
                    "weaponsfound" -> stats.weaponsFound
                    "gearfound" -> stats.gearFound
                    "junkfound" -> stats.junkFound
                    "medicalfound" -> stats.medicalFound
                    "craftingfound" -> stats.craftingFound
                    "researchfound" -> stats.researchFound
                    "researchnotefound" -> stats.researchNoteFound
                    "clothingfound" -> stats.clothingFound
                    "cratesfound" -> stats.cratesFound
                    "schematicsfound" -> stats.schematicsFound
                    "effectfound" -> stats.effectFound
                    "rareweaponfound" -> stats.rareWeaponFound
                    "raregearfound" -> stats.rareGearFound
                    "uniqueweaponfound" -> stats.uniqueWeaponFound
                    "uniquegearfound" -> stats.uniqueGearFound
                    "greyweaponfound" -> stats.greyWeaponFound
                    "greygearfound" -> stats.greyGearFound
                    "whiteweaponfound" -> stats.whiteWeaponFound
                    "whitegearfound" -> stats.whiteGearFound
                    "greenweaponfound" -> stats.greenWeaponFound
                    "greengearfound" -> stats.greenGearFound
                    "blueweaponfound" -> stats.blueWeaponFound
                    "bluegearfound" -> stats.blueGearFound
                    "purpleweaponfound" -> stats.purpleWeaponFound
                    "purplegearfound" -> stats.purpleGearFound
                    "premiumweaponfound" -> stats.premiumWeaponFound
                    "premiumgearfound" -> stats.premiumGearFound
                    // Check custom data for special stats
                    else -> stats.customData[statId] ?: stats.killData[statId] ?: 0
                }
            }
            GoalType.ITEM -> {
                // Count items in inventory
                if (inventory == null) {
                    Logger.warn { "ITEM goal requires inventory but it was not provided (goal: ${goal.id}, target: ${goal.value})" }
                    return 0
                }

                val itemId = goal.id ?: return 0
                val itemsInInventory = inventory.inventory

                // Count items matching the goal
                // Goal ID can be either:
                // - Specific item ID (e.g., "pipe")
                // - Item type (e.g., "weapon", "gear")
                val count = itemsInInventory.count { item ->
                    when {
                        // Exact item ID match
                        item.type.equals(itemId, ignoreCase = true) -> true
                        // Item type match - check against GameDefinition
                        else -> {
                            val itemResource = GameDefinition.findItem(item.type)
                            itemResource?.type?.equals(itemId, ignoreCase = true) == true
                        }
                    }
                }
                count
            }
            GoalType.TASK -> {
                // TASK goals would track completion of specific tasks
                // Currently no quests use TASK goals in the XML
                // Tasks are in PlayerObjects.tasks, but unclear what completion tracking means
                // TODO: Define what "task completion" means and implement if needed
                Logger.warn { "TASK goal type not yet implemented - no current usage (goal: ${goal.id}, target: ${goal.value})" }
                0
            }
        }
    }

    /**
     * Get all available quests with their progress
     */
    fun getAvailableQuestsWithProgress(
        playerObjects: PlayerObjects,
        inventory: data.collection.Inventory? = null
    ): Map<String, QuestProgress> {
        val result = mutableMapOf<String, QuestProgress>()

        for ((questId, questDef) in GameDefinition.questsById) {
            // Skip if already completed and collected
            if (isQuestCompleted(questId, playerObjects) && isQuestCollected(questId, playerObjects)) {
                continue
            }

            // Check if prerequisites are met
            if (!checkPrerequisites(questDef, playerObjects)) {
                continue
            }

            // Get progress for this quest
            val progress = checkQuestObjectives(questDef, playerObjects, inventory)
            result[questId] = progress
        }

        return result
    }

    /**
     * Get the index of a quest in the quest list
     */
    private fun getQuestIndex(questId: String): Int {
        val quest = GameDefinition.findQuest(questId)
        if (quest != null) {
            // Find the index by counting all quests before this one
            return GameDefinition.questsById.keys.sorted().indexOf(questId)
        }

        val achievement = GameDefinition.findAchievement(questId)
        if (achievement != null) {
            return GameDefinition.achievementsById.keys.sorted().indexOf(questId)
        }

        return -1
    }

    /**
     * Parse quest completion status from byte array
     */
    private fun parseQuestCompletionStatus(bytes: ByteArray?): List<Boolean> {
        if (bytes == null || bytes.isEmpty()) {
            return emptyList()
        }

        val result = mutableListOf<Boolean>()
        for (byte in bytes) {
            for (i in 0 until 8) {
                val bit = (byte.toInt() shr i) and 1
                result.add(bit == 1)
            }
        }
        return result
    }

    /**
     * Convert boolean list to byte array
     */
    private fun booleanListToByteArray(booleans: List<Boolean>): ByteArray {
        val numBytes = (booleans.size + 7) / 8
        val bytes = ByteArray(numBytes)

        for (i in booleans.indices) {
            if (booleans[i]) {
                val byteIndex = i / 8
                val bitIndex = i % 8
                bytes[byteIndex] = (bytes[byteIndex].toInt() or (1 shl bitIndex)).toByte()
            }
        }

        return bytes
    }
}

/**
 * Result of calculating quest rewards
 */
data class QuestRewardResult(
    val xp: Int,
    val items: List<RewardItem>
)

/**
 * Individual reward item
 */
data class RewardItem(
    val type: RewardItemType,
    val id: String,
    val quantity: Int
)

enum class RewardItemType {
    ITEM,
    RESOURCE
}

/**
 * Quest progress information
 */
data class QuestProgress(
    val questId: String,
    val isCompleted: Boolean,
    val objectives: Map<String, ObjectiveProgress>
)

/**
 * Progress for a single objective
 */
data class ObjectiveProgress(
    val current: Int,
    val target: Int,
    val isCompleted: Boolean
)
