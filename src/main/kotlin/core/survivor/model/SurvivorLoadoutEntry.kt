package core.model.game.data

import core.data.AdminData
import kotlinx.serialization.Serializable

@Serializable
data class SurvivorLoadoutEntry(
    val weapon: String,  // weapon id
    val gear1: String,  // gear id (passive)
    val gear2: String,  // gear id (active)
    val gear2_qty: Int = 1  // quantity for active gear (grenades, medkits, etc.)
) {
    companion object {
        fun playerLoudout(): SurvivorLoadoutEntry {
            return SurvivorLoadoutEntry(
                weapon = AdminData.PLAYER_WEP_ID,
                gear1 = "",
                gear2 = "",
                gear2_qty = 0
            )
        }

        fun fighterLoadout(): SurvivorLoadoutEntry {
            return SurvivorLoadoutEntry(
                weapon = AdminData.FIGHTER_WEP_ID,
                gear1 = "",
                gear2 = "",
                gear2_qty = 0
            )
        }

        fun reconLoadout(): SurvivorLoadoutEntry {
            return SurvivorLoadoutEntry(
                weapon = AdminData.RECON_WEP_ID,
                gear1 = "",
                gear2 = "",
                gear2_qty = 0
            )
        }
    }
}
