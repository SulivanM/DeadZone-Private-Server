package core.model.game.data

import core.data.AdminData
import core.model.game.data.SurvivorAppearance.Companion.toHumanAppearance
import core.survivor.model.injury.Injury
import core.survivor.model.injury.InjuryList
import dev.deadzone.core.model.game.data.TimerData
import common.UUID
import kotlinx.serialization.Serializable

@Serializable
data class Survivor(
    val id: String = UUID.new(),
    val title: String,
    val firstName: String = "",
    val lastName: String = "DZ",
    val gender: String,
    val portrait: String? = null,
    val classId: String,
    val morale: Map<String, Double> = emptyMap(),
    val injuries: List<Injury> = emptyList(),
    val level: Int = 0,
    val xp: Int = 0,
    val missionId: String? = null,
    val assignmentId: String? = null,
    val reassignTimer: TimerData? = null,
    val appearance: HumanAppearance? = null, // HumanAppearance > SurvivorAppearance
    val scale: Double = 1.22,
    val voice: String,
    val accessories: Map<String, String> = emptyMap(),  // key is parsed to int, string is accessory id
    val maxClothingAccessories: Int = 1
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
                morale = emptyMap(),
                injuries = InjuryList().list,
                level = 0,
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
                morale = emptyMap(),
                injuries = InjuryList().list,
                level = 0,
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
                morale = emptyMap(),
                injuries = InjuryList().list,
                level = 0,
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