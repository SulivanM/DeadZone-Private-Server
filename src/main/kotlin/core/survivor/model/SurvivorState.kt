package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class SurvivorState(val value: UInt)

object SurvivorState_Constants {
    val AVAILABLE = SurvivorState(0u)
    val ON_MISSION = SurvivorState(1u)
    val ON_TASK = SurvivorState(2u)
    val REASSIGNING = SurvivorState(4u)
    val ON_ASSIGNMENT = SurvivorState(8u)
}
