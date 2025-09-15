package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class SurvivorClassConstants(val value: String)

object SurvivorClassConstants_Constants {
    val FIGHTER = SurvivorClassConstants("fighter")
    val MEDIC = SurvivorClassConstants("medic")
    val SCAVENGER = SurvivorClassConstants("scavenger")
    val ENGINEER = SurvivorClassConstants("engineer")
    val RECON = SurvivorClassConstants("recon")
    val PLAYER = SurvivorClassConstants("player")
    val UNASSIGNED = SurvivorClassConstants("unassigned")
}
