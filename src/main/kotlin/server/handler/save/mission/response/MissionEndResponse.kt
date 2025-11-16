package server.handler.save.mission.response

import core.items.model.Item
import core.model.game.data.Morale
import core.model.game.data.MissionStats
import core.model.game.data.assignment.AssignmentResult
import core.survivor.model.injury.Injury
import dev.deadzone.core.model.game.data.TimerData
import kotlinx.serialization.Serializable

/**
 * Mission End Response sent to client after MISSION_END request.
 * 
 * This response structure matches what the client expects in MissionData.as:onMissionEndSaved()
 * The client processes this data to:
 * - Update survivor XP/levels
 * - Show mission results dialogue 
 * - Apply injuries to survivors
 * - Give loot to player
 * - Set return timer for automated missions
 * - Update item counters (weapon kill counts)
 * - Handle assignment results (Raid/Arena)
 * - Process PvP-specific data (bounty, alliance flags)
 */
@Serializable
data class MissionEndResponse(
    // ===== Core Mission Data (always present) =====
    
    /** Whether this was an automated mission (true = no gameplay, false = player controlled) */
    val automated: Boolean = false,
    
    /** Total XP earned from mission (zombie kills, objectives, etc.) */
    val xpEarned: Int = 0,
    
    /** XP breakdown by category (for UI display) */
    val xp: XpBreakdown? = null,
    
    /** Timer for mission return (when automated=true) */
    val returnTimer: TimerData? = null,
    
    /** Lock timer preventing mission restart (optional) */
    val lockTimer: TimerData? = null,
    
    /** Items looted during mission */
    val loot: List<Item> = emptyList(),
    
    /** 
     * Item counter values - tracks internal weapon/item state
     * Maps item ID to counter value (e.g., weapon kill count)
     * Client updates inventory items with these values
     */
    val itmCounters: Map<String, Int> = emptyMap(),
    
    /** 
     * Injuries sustained during mission
     * Each entry contains: success (true=died), srv (survivor ID), inj (injury object)
     */
    val injuries: List<InjuryData>? = null,
    
    /** Survivor results (XP gained, levels, morale changes) */
    val survivors: List<SurvivorResult> = emptyList(),
    
    /** Player survivor results (XP/level) */
    val player: PlayerSurvivor = PlayerSurvivor(),
    
    /** Total available level points for player */
    val levelPts: Int = 0,
    
    /** Base64 encoded cooldown data (optional) */
    val cooldown: String? = null,
    
    /** Mission statistics for display and tracking */
    val stats: MissionStats? = null,
    
    // ===== PvP-specific fields =====
    
    /** Whether bounty was collected in PvP mission */
    val bountyCollect: Boolean = false,
    
    /** Bounty amount collected */
    val bounty: Double? = null,
    
    /** Whether alliance flag was captured */
    val allianceFlagCaptured: Boolean = false,
    
    /** Bounty cap limit */
    val bountyCap: Int? = null,
    
    /** Timestamp when bounty cap resets */
    val bountyCapTimestamp: Long? = null,
    
    // ===== Assignment-specific fields (Raid/Arena) =====
    
    /** Assignment result data for Raid/Arena missions */
    val assignmentresult: AssignmentResult? = null
)

/**
 * XP breakdown showing how XP was earned
 */
@Serializable
data class XpBreakdown(
    /** Total XP earned */
    val total: Int? = 0
)

/**
 * Injury data for a survivor
 * Matches client structure in MissionData.as:applyInjuriesFromList()
 */
@Serializable
data class InjuryData(
    /** Survivor ID */
    val srv: String,
    
    /** Injury object with type, location, severity, etc. */
    val inj: Injury,
    
    /** Whether survivor died (true) or just injured (false) */
    val success: Boolean = false
)

/**
 * Survivor mission result data
 * Contains post-mission XP, level, and morale
 */
@Serializable
data class SurvivorResult(
    /** Survivor ID */
    val id: String,
    
    /** End XP after mission */
    val xp: Int,
    
    /** End level after mission */
    val level: Int,
    
    /** Morale changes (optional) */
    val morale: Morale? = null
)

/**
 * Player survivor (leader) result data
 */
@Serializable
data class PlayerSurvivor(
    /** Player survivor end XP */
    val xp: Int = 0,
    
    /** Player survivor end level */
    val level: Int = 1
)
