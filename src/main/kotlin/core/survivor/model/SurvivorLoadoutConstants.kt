package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class SurvivorLoadoutConstants(val value: String)

object SurvivorLoadoutConstants_Constants {
    val SLOT_WEAPON = SurvivorLoadoutConstants("weapon")
    val SLOT_GEAR_PASSIVE = SurvivorLoadoutConstants("gearPassive")
    val SLOT_GEAR_ACTIVE = SurvivorLoadoutConstants("gearActive")
    val TYPE_OFFENCE = SurvivorLoadoutConstants("offence")
    val TYPE_DEFENCE = SurvivorLoadoutConstants("defence")
}
