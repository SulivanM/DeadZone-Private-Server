package core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class HumanAppearance(
    val forceHair: Boolean = false,
    val hideGear: Boolean = false,
    val hairColor: String = "black",
    val skinColor: String? = null,
    val hair: String? = null,
    val facialHair: String? = null,
    val clothing_upper: String? = null,
    val clothing_lower: String? = null,
    val accessories: List<String>? = null
) {
    companion object {
        fun parse(app: Map<*, *>): HumanAppearance {
            return HumanAppearance(
                forceHair = app["forceHair"] as? Boolean ?: false,
                hideGear = app["hideGear"] as? Boolean ?: false,
                hairColor = app["hairColor"] as? String ?: "black",
                skinColor = app["skinColor"] as? String,
                hair = app["hair"] as? String,
                facialHair = app["facialHair"] as? String,
                clothing_upper = app["upper"] as? String,
                clothing_lower = app["lower"] as? String,
                accessories = (app["accessories"] as? List<*>)?.mapNotNull { it as? String }
            )
        }
    }
}
