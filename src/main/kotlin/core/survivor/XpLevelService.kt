package core.survivor

import core.model.game.data.Survivor
import data.collection.PlayerObjects
import common.Logger
import common.LogConfigSocketError

/**
 * Centralized service for all XP and level calculations
 * Ensures consistency across missions, quests, and other XP sources
 */
object XpLevelService {
    // Match client constants from Config.as
    private const val BASE_XP_MULTIPLIER = 1
    private const val LEVEL_XP_MULTIPLIER = 100
    private const val MAX_SURVIVOR_LEVEL = 50 // Default max level
    private const val REST_XP_BONUS = 1.5 // 50% bonus when using rested XP

    /**
     * Result of XP gain calculation
     */
    data class XpGainResult(
        val updatedSurvivor: Survivor,
        val newLevelPts: Int,  // New level points earned from this XP gain
        val restedXpConsumed: Int  // Amount of rested XP consumed
    )

    /**
     * Calculate XP required to reach a specific level from level 0
     * Formula matches client: LEVEL_XP_MULTIPLIER * level² * BASE_XP_MULTIPLIER
     *
     * @param level Target level (0-based, like client)
     * @return Total XP needed to reach this level from level 0
     */
    fun calculateXpForLevel(level: Int): Int {
        if (level <= 0) return 0
        return LEVEL_XP_MULTIPLIER * level * level * BASE_XP_MULTIPLIER
    }

    /**
     * Calculate XP required for next level from current level
     *
     * @param currentLevel Current level (0-based)
     * @return XP required to go from currentLevel to currentLevel+1
     */
    fun calculateXpForNextLevel(currentLevel: Int): Int {
        val nextLevel = currentLevel + 1
        return calculateXpForLevel(nextLevel)
    }

    /**
     * Calculate what level a survivor should be at given total cumulative XP
     * Returns the level and any new level points earned
     *
     * @param currentLevel Survivor's current level before XP gain
     * @param currentTotalXp Survivor's current total cumulative XP
     * @param newTotalXp New total cumulative XP after gain
     * @return Pair of (new level, new level points earned)
     */
    fun calculateLevelFromTotalXp(
        currentLevel: Int,
        currentTotalXp: Int,
        newTotalXp: Int
    ): Pair<Int, Int> {
        var level = 0
        var totalXpNeeded = 0

        // Calculate the level based on total XP from scratch
        while (level < MAX_SURVIVOR_LEVEL) {
            val xpForNextLevel = calculateXpForNextLevel(level)
            if (newTotalXp >= totalXpNeeded + xpForNextLevel) {
                totalXpNeeded += xpForNextLevel
                level++
            } else {
                break
            }
        }

        // Cap at max level
        if (level > MAX_SURVIVOR_LEVEL) {
            level = MAX_SURVIVOR_LEVEL
        }

        // Calculate new level points earned
        val levelPts = level - currentLevel

        return Pair(level, levelPts)
    }

    /**
     * Apply rested XP bonus to earned XP
     * Matches client formula: REST_XP_BONUS - 1 applied to base XP
     *
     * @param earnedXp Base XP earned without bonus
     * @param availableRestedXp Available rested XP in the bank
     * @return Pair of (total XP with bonus applied, rested XP consumed)
     */
    fun applyRestedXpBonus(earnedXp: Int, availableRestedXp: Int): Pair<Int, Int> {
        if (availableRestedXp <= 0) {
            return Pair(earnedXp, 0)
        }

        // Calculate bonus XP (50% of earned XP with REST_XP_BONUS = 1.5)
        val bonusMultiplier = REST_XP_BONUS - 1.0
        val bonusXp = (earnedXp * bonusMultiplier).toInt()

        // Total XP that would be awarded with full bonus
        val totalXpWithBonus = earnedXp + bonusXp

        // Check if we have enough rested XP to cover the full bonus
        val restedXpConsumed = if (totalXpWithBonus > availableRestedXp) {
            // Not enough rested XP, consume all available
            availableRestedXp
        } else {
            // Enough rested XP for full bonus
            totalXpWithBonus
        }

        return Pair(earnedXp + restedXpConsumed, restedXpConsumed)
    }

    /**
     * Add XP to a survivor with automatic level-up and rested XP bonus
     * This is the main entry point for all XP gains
     *
     * @param survivor The survivor to add XP to
     * @param earnedXp Base XP earned (before rested bonus)
     * @param availableRestedXp Available rested XP for bonus (default 0)
     * @param maxLevel Maximum level cap (default MAX_SURVIVOR_LEVEL)
     * @return XpGainResult with updated survivor, new level points, and rested XP consumed
     */
    fun addXpToSurvivor(
        survivor: Survivor,
        earnedXp: Int,
        availableRestedXp: Int = 0,
        maxLevel: Int = MAX_SURVIVOR_LEVEL
    ): XpGainResult {
        // Apply rested XP bonus if available
        val (totalXp, restedXpConsumed) = applyRestedXpBonus(earnedXp, availableRestedXp)

        // Calculate new total XP (server stores cumulative XP)
        val newTotalXp = survivor.xp + totalXp

        // Calculate new level and level points
        val (newLevel, newLevelPts) = calculateLevelFromTotalXp(
            currentLevel = survivor.level,
            currentTotalXp = survivor.xp,
            newTotalXp = newTotalXp
        )

        // Cap at provided max level
        val cappedLevel = newLevel.coerceAtMost(maxLevel)

        // If we hit max level, cap XP at the total needed for max level
        val cappedXp = if (cappedLevel >= maxLevel) {
            calculateXpForLevel(maxLevel)
        } else {
            newTotalXp
        }

        // Create updated survivor
        val updatedSurvivor = survivor.copy(
            xp = cappedXp,
            level = cappedLevel
        )

        Logger.info {
            "XP Gain: survivor=${survivor.id}, " +
            "level ${survivor.level}->${cappedLevel} (+${newLevelPts}), " +
            "xp ${survivor.xp}->${cappedXp} (+${totalXp}), " +
            "rested consumed: $restedXpConsumed"
        }

        return XpGainResult(
            updatedSurvivor = updatedSurvivor,
            newLevelPts = newLevelPts,
            restedXpConsumed = restedXpConsumed
        )
    }

    /**
     * Add XP to the player leader with level points update
     * This updates both the survivor and the PlayerObjects.levelPts
     *
     * @param survivor The leader survivor
     * @param playerObjects Current PlayerObjects
     * @param earnedXp Base XP earned
     * @return Pair of (updated survivor, updated PlayerObjects)
     */
    fun addXpToLeader(
        survivor: Survivor,
        playerObjects: PlayerObjects,
        earnedXp: Int
    ): Pair<Survivor, PlayerObjects> {
        // Apply XP gain with rested XP bonus
        val result = addXpToSurvivor(
            survivor = survivor,
            earnedXp = earnedXp,
            availableRestedXp = playerObjects.restXP
        )

        // Update PlayerObjects with new levelPts and consumed rested XP
        val updatedPlayerObjects = playerObjects.copy(
            levelPts = playerObjects.levelPts + result.newLevelPts.toUInt(),
            restXP = (playerObjects.restXP - result.restedXpConsumed).coerceAtLeast(0)
        )

        return Pair(result.updatedSurvivor, updatedPlayerObjects)
    }

    /**
     * Get current XP progress toward next level
     * This is what the client uses for the XP progress bar
     *
     * @param totalXp Total cumulative XP
     * @param currentLevel Current level
     * @return XP progress toward next level (0 to XPForNextLevel)
     */
    fun getXpProgressToNextLevel(totalXp: Int, currentLevel: Int): Int {
        // Calculate total XP needed to reach current level
        val xpForCurrentLevel = calculateXpForLevel(currentLevel)

        // Progress is total XP minus XP needed for current level
        return totalXp - xpForCurrentLevel
    }

    /**
     * Calculate XP needed for next level from current XP
     *
     * @param currentLevel Current level
     * @return XP requirement for next level
     */
    fun getXpRequiredForNextLevel(currentLevel: Int): Int {
        return calculateXpForNextLevel(currentLevel)
    }
}
