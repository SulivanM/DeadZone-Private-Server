package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class MissionDataConstants(val value: Int)

object MissionDataConstants_Constants {
    val DANGER_NORMAL = MissionDataConstants(0)
    val DANGER_LOW = MissionDataConstants(0)
    val DANGER_MODERATE = MissionDataConstants(1)
    val DANGER_DANGEROUS = MissionDataConstants(2)
    val DANGER_HIGH = MissionDataConstants(3)
    val DANGER_EXTREME = MissionDataConstants(4)
}
