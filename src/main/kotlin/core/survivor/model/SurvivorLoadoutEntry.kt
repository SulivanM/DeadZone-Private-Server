package core.model.game.data

import core.data.AdminData
import kotlinx.serialization.Serializable

@Serializable
data class SurvivorLoadoutEntry(
    val weapon: String,
    val gear1: String,
    val gear2: String,
) {
    companion object {
        fun playerLoudout(): SurvivorLoadoutEntry {
            return SurvivorLoadoutEntry(
                weapon = AdminData.PLAYER_WEP_ID,
                gear1 = "",
                gear2 = "",
            )
        }

        fun fighterLoadout(): SurvivorLoadoutEntry {
            return SurvivorLoadoutEntry(
                weapon = AdminData.FIGHTER_WEP_ID,
                gear1 = "",
                gear2 = "",
            )
        }

        fun reconLoadout(): SurvivorLoadoutEntry {
            return SurvivorLoadoutEntry(
                weapon = AdminData.RECON_WEP_ID,
                gear1 = "",
                gear2 = "",
            )
        }
    }
}
