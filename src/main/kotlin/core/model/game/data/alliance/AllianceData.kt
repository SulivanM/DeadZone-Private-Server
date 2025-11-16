package core.model.game.data.alliance

import kotlinx.serialization.Serializable
import core.model.game.data.alliance.AllianceDataSummary
import core.model.game.data.alliance.AllianceList
import core.model.game.data.alliance.AllianceMemberList
import core.model.game.data.alliance.AllianceMessageList
import core.model.game.data.effects.Effect
import core.model.game.data.alliance.TargetRecord

@Serializable
data class AllianceData(
    val allianceDataSummary: AllianceDataSummary,
    val members: AllianceMemberList?,
    val messages: AllianceMessageList?,
    val enemies: AllianceList?,
    val ranks: Map<String, Int>?,
    val bannerEdits: Int,
    val effects: List<Effect>?,
    val tokens: Int?,
    val taskSet: Int?,
    val tasks: Map<String, Int>?, // string as key, but parsed to int
    val attackedTargets: Map<String, TargetRecord>?,
    val scoutedTargets: Map<String, TargetRecord>?
)
