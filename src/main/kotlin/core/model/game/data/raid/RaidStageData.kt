package core.model.game.data.raid

import kotlinx.serialization.Serializable
import core.model.game.data.assignment.AssignmentStageData

@Serializable
data class RaidStageData(
    val assignmentStageData: AssignmentStageData,
    val objectiveIndex: Int,
    val objectiveState: RaidStageObjectiveState = RaidStageObjectiveState_Constants.INCOMPLETE,
    val objectiveXML: String?,
    val imageURI: String
)
