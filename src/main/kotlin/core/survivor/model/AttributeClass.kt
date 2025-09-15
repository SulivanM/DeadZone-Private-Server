package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class AttributeClass(val value: String)

object AttributeClass_Constants {
    val FIGHTING_1 = AttributeClass("combatProjectile")
    val FIGHTING_2 = AttributeClass("combatMelee")
    val SCAVENGING_1 = AttributeClass("scavenge")
    val ENGINEERING_1 = AttributeClass("combatImprovised")
    val ENGINEERING_2 = AttributeClass("trapDisarming")
    val MEDIC_1 = AttributeClass("healing")
    val RECON_1 = AttributeClass("movement")
    val RECON_2 = AttributeClass("trapSpotting")
}
