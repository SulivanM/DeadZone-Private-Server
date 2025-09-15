package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class AttributesConstants(val value: String)

object AttributesConstants_Constants {
    val COMBAT_IMPROVISED = AttributesConstants("combatImprovised")
    val COMBAT_PROJECTILE = AttributesConstants("combatProjectile")
    val COMBAT_MELEE = AttributesConstants("combatMelee")
    val MOVEMENT_SPEED = AttributesConstants("movement")
    val SCAVENGE_SPEED = AttributesConstants("scavenge")
    val HEALING = AttributesConstants("healing")
    val TRAP_SPOTTING = AttributesConstants("trapSpotting")
    val TRAP_DISARMING = AttributesConstants("trapDisarming")
    val HEALTH = AttributesConstants("health")
    val INJURY_CHANCE = AttributesConstants("injuryChance")
}
