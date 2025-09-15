package dev.deadzone.core.model.game.data.raid

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class RaidStageObjectiveState(val value: UInt)

object RaidStageObjectiveState_Constants {
    val INCOMPLETE = RaidStageObjectiveState(0u)
    val COMPLETE = RaidStageObjectiveState(1u)
    val FAILED = RaidStageObjectiveState(2u)
}
