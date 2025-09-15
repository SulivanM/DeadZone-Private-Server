package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

// subclass of HumanAppearance though its deserialize don't work
@Serializable
data class SurvivorAppearance(
    val skinColor: String?,
    val upper: String?,
    val lower: String?,
    val hair: String?,
    val facialHair: String?,
    val hairColor: String?,
    val forceHair: Boolean = false,
    val hideGear: Boolean = false
) {
    companion object {
        fun SurvivorAppearance.toHumanAppearance(): HumanAppearance {
            return HumanAppearance(
                skinColor = this.skinColor,
                hair = this.hair,
                facialHair = this.facialHair,
                clothing_upper = this.upper,
                clothing_lower = this.lower,
                hairColor = this.hairColor ?: "black",
                forceHair = this.forceHair,
                hideGear = this.hideGear,
                accessories = emptyList()
            )
        }

        fun playerM(): SurvivorAppearance {
            return SurvivorAppearance(
                skinColor = "light1",
                upper = "hoodie",
                lower = "pants",
                hair = "hair1",
                facialHair = "facialHair0",
                hairColor = "darkBrown",
                forceHair = false,
                hideGear = false
            )
        }

        fun fighterM(): SurvivorAppearance {
            return SurvivorAppearance(
                skinColor = "light1",
                upper = "class_fighter",
                lower = "class_fighter",
                hair = "hair1",
                facialHair = "facialHair0",
                hairColor = "darkBrown",
                forceHair = false,
                hideGear = false
            )
        }

        fun reconF(): SurvivorAppearance {
            return SurvivorAppearance(
                skinColor = "light1",
                upper = "class_recon",
                lower = "class_recon",
                hair = "hair1",
                facialHair = null,
                hairColor = "darkBrown",
                forceHair = false,
                hideGear = false
            )
        }
    }
}
