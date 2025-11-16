package core.model.game.data

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
        /**
         * Base attributes for a new player character
         */
        fun starter(): Attributes {
            return Attributes(
                health = 100.0,
                combatProjectile = 1.0,
                combatMelee = 1.0,
                combatImprovised = 1.0,
                movement = 1.0,
                scavenge = 1.0,
                healing = 1.0,
                trapSpotting = 1.0,
                trapDisarming = 1.0,
                injuryChance = 1.0,
            )
        }
    }
}
