package dev.deadzone.core.model.game.data

import dev.deadzone.core.data.AdminData
import kotlinx.serialization.Serializable

@Serializable
data class SurvivorLoadoutEntry(
    val weapon: String,  // weapon id
    val gear1: String,  // gear id
    val gear2: String,  // gear id
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
