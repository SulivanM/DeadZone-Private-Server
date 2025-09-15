package dev.deadzone.socket.handler.save.mission.response

import dev.deadzone.core.items.model.Item
import dev.deadzone.core.model.game.data.Morale
import dev.deadzone.core.model.game.data.TimerData
import dev.deadzone.core.model.game.data.assignment.AssignmentResult
import dev.deadzone.core.survivor.model.injury.Injury
import kotlinx.serialization.Serializable

@Serializable
data class MissionEndResponse(
    // For isPvPPractice
    val bountyCollect: Boolean = false,
    val bounty: Double? = null,
    val allianceFlagCaptured: Boolean = false,
    val bountyCap: Int? = null,
    val bountyCapTimestamp: Long? = null,

    // If assignment type is raid or arena
    val assignmentresult: AssignmentResult? = null,

    // For onMissionEndSaved, required
    val automated: Boolean = false,
    val xpEarned: Int = 120,
    val xp: XpBreakdown? = null,
    val returnTimer: TimerData? = null,
    val lockTimer: TimerData? = null,
    val loot: List<Item> = emptyList(),
    val itmCounters: Map<String, Int> = emptyMap(), // item id to quantity
    val injuries: List<InjuryData>? = null,
    val survivors: List<SurvivorResult> = emptyList(),
    val player: PlayerSurvivor = PlayerSurvivor(),
    val levelPts: Int = 0,
    val cooldown: String? = null // base64 encoded string
)

@Serializable
data class XpBreakdown(
    val total: Int? = 120,
)

@Serializable
data class InjuryData(
    val success: Boolean = false, // false = didn't die
    val survivorId: String,
    val injury: Injury
)

@Serializable
data class SurvivorResult(
    val id: String, // survivor id
    val morale: Morale? = null,
    val xp: Int,
    val level: Int
)

@Serializable
data class PlayerSurvivor(
    val xp: Int = 120, // end xp after mission
    val level: Int = 60 // end level after mission
    // obviously, should be higher than before unless xp decrease is intended
)
