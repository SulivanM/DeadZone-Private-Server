package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class Attributes(
    val health: Double = 0.0,
    val combatProjectile: Double = 0.0,
    val combatMelee: Double = 0.0,
    val combatImprovised: Double = 0.0,
    val movement: Double = 0.0,
    val scavenge: Double = 0.0,
    val healing: Double = 0.0,
    val trapSpotting: Double = 0.0,
    val trapDisarming: Double = 0.0,
    val injuryChance: Double = 0.0
) {
    companion object {
        fun dummy(): Attributes {
            return Attributes(
                health = 100.0,
                combatProjectile = 2.0,
                combatMelee = 2.0,
                combatImprovised = 2.0,
                movement = 2.0,
                scavenge = 2.0,
                healing = 2.0,
                trapSpotting = 2.0,
                trapDisarming = 2.0,
                injuryChance = 2.0,
            )
        }
    }
}
