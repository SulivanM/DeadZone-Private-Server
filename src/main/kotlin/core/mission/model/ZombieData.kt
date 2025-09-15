package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class ZombieData(
    val id: Int,
    val type: String,
    val weapon: String
) {
    companion object {
        fun standardZombieWeakAttack(id: Int): ZombieData {
            return ZombieData(id = id, type = "standard", weapon = "zStrike")
        }

        fun dogStandard(id: Int): ZombieData {
            return ZombieData(id = id, type = "dog", weapon = "zDogBite")
        }

        fun fatWalkerStrongAttack(id: Int): ZombieData {
            return ZombieData(id = id, type = "fat-walker", weapon = "zStrongStrike")
        }

        fun police20ZWeakAttack(id: Int): ZombieData {
            return ZombieData(id = id, type = "police-20", weapon = "zStrike")
        }

        fun riotWalker37MediumAttack(id: Int): ZombieData {
            return ZombieData(id = id, type = "riot-walker-37", weapon = "zMediumStrike")
        }

        fun dogTank(id: Int): ZombieData {
            return ZombieData(id = id, type = "dog-tank", weapon = "zDogBite")
        }

        fun strongRunner(id: Int): ZombieData {
            return ZombieData(id = id, type = "strong-runner", weapon = "zKnockbackStrike")
        }
    }
}

fun ZombieData.toFlatList(): List<String> {
    return listOf("$id", type, weapon)
}
