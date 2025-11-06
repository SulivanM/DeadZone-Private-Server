package server.handler.save.mission.response

import core.items.model.Item
import core.model.game.data.Morale
import core.model.game.data.assignment.AssignmentResult
import core.survivor.model.injury.Injury
import dev.deadzone.core.model.game.data.TimerData
import kotlinx.serialization.Serializable

@Serializable
data class MissionEndResponse(
    
    val bountyCollect: Boolean = false,
    val bounty: Double? = null,
    val allianceFlagCaptured: Boolean = false,
    val bountyCap: Int? = null,
    val bountyCapTimestamp: Long? = null,

    val assignmentresult: AssignmentResult? = null,

    val automated: Boolean = false,
    val xpEarned: Int = 120,
    val xp: XpBreakdown? = null,
    val returnTimer: TimerData? = null,
    val lockTimer: TimerData? = null,
    val loot: List<Item> = emptyList(),
    val itmCounters: Map<String, Int> = emptyMap(), 
    val injuries: List<InjuryData>? = null,
    val survivors: List<SurvivorResult> = emptyList(),
    val player: PlayerSurvivor = PlayerSurvivor(),
    val levelPts: Int = 0,
    val cooldown: String? = null 
)

@Serializable
data class XpBreakdown(
    val total: Int? = 120,
)

@Serializable
data class InjuryData(
    val success: Boolean = false, 
    val survivorId: String,
    val injury: Injury
)

@Serializable
data class SurvivorResult(
    val id: String, 
    val morale: Morale? = null,
    val xp: Int,
    val level: Int
)

@Serializable
data class PlayerSurvivor(
    val xp: Int = 120, 
    val level: Int = 60 
    
)
