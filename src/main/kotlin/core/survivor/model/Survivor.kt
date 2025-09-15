package dev.deadzone.core.model.game.data

import dev.deadzone.core.data.AdminData
import dev.deadzone.core.model.game.data.SurvivorAppearance.Companion.toHumanAppearance
import dev.deadzone.core.survivor.model.injury.Injury
import dev.deadzone.core.survivor.model.injury.InjuryList
import dev.deadzone.utils.UUID
import kotlinx.serialization.Serializable

@Serializable
data class Survivor(
    val id: String = UUID.new(),
    val title: String,
    val firstName: String = "",
    val lastName: String = "",
    val gender: String,
    val portrait: String? = null,
    val classId: String,
    val morale: Map<String, Double>,
    val injuries: List<Injury>,
    val level: Int,
    val xp: Int,
    val missionId: String?,
    val assignmentId: String?,
    val reassignTimer: TimerData? = null,
    val appearance: HumanAppearance? = null, // HumanAppearance > SurvivorAppearance
    val scale: Double = 1.22,
    val voice: String,
    val accessories: Map<String, String>,  // key is parsed to int, string is accessory id
    val maxClothingAccessories: Int
) {
    companion object {
        fun playerM(): Survivor {
            return Survivor(
                id = AdminData.PLAYER_SRV_ID,
                title = "MercifulLeader",
                firstName = "Merciful",
                lastName = "Leader",
                gender = Gender_Constants.MALE.value,
                portrait = null,
                classId = SurvivorClassConstants_Constants.PLAYER.value,
                morale = Morale().maps,
                injuries = InjuryList().list,
                level = 59,
                xp = 1000,
                missionId = null,
                assignmentId = null,
                reassignTimer = null,
                appearance = SurvivorAppearance.playerM().toHumanAppearance(),
                scale = 1.22,
                voice = "asian-m",
                accessories = mapOf(),
                maxClothingAccessories = 10
            )
        }

        fun reconF(): Survivor {
            return Survivor(
                id = AdminData.RECON_SRV_ID,
                title = "NoisyRecon",
                firstName = "Noisy",
                lastName = "Recon",
                gender = Gender_Constants.FEMALE.value,
                portrait = null,
                classId = SurvivorClassConstants_Constants.RECON.value,
                morale = Morale().maps,
                injuries = InjuryList().list,
                level = 59,
                xp = 1000,
                missionId = null,
                assignmentId = null,
                reassignTimer = null,
                appearance = SurvivorAppearance.reconF().toHumanAppearance(),
                scale = 1.22,
                voice = "white-f",
                accessories = mapOf(),
                maxClothingAccessories = 10
            )
        }

        fun fighterM(): Survivor {
            return Survivor(
                id = AdminData.FIGHTER_SRV_ID,
                title = "AngryFighter",
                firstName = "Angry",
                lastName = "Fighter",
                gender = Gender_Constants.MALE.value,
                portrait = null,
                classId = SurvivorClassConstants_Constants.FIGHTER.value,
                morale = Morale().maps,
                injuries = InjuryList().list,
                level = 59,
                xp = 1000,
                missionId = null,
                assignmentId = null,
                reassignTimer = null,
                appearance = SurvivorAppearance.fighterM().toHumanAppearance(),
                scale = 1.18,
                voice = "asian-m",
                accessories = mapOf(),
                maxClothingAccessories = 10
            )
        }
    }
}
