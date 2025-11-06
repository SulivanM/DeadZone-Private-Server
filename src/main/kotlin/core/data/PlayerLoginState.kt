package core.data

import core.model.game.data.GameResources
import core.model.game.data.Survivor
import kotlinx.serialization.Serializable

@Serializable
data class PlayerLoginState(
    
    val settings: Map<String, String> = emptyMap(),
    val news: Map<String, String> = emptyMap(), 
    val sales: List<String> = emptyList(), 
    val allianceWinnings: Map<String, String> = emptyMap(),
    val recentPVPList: List<String> = emptyList(),

    val invsize: Int,
    val upgrades: String = "", 
    val allianceId: String? = null,
    val allianceTag: String? = null,
    val longSession: Boolean = false, 
    val leveledUp: Boolean = false,
    val promos: List<String> = emptyList(),
    val promoSale: String? = null,
    val dealItem: String? = null,
    val leaderResets: Int = 0,
    val unequipItemBinds: List<String> = emptyList(),
    val globalStats: Map<String, List<String>> = mapOf(
        "idList" to emptyList()
    ),

    val resources: GameResources? = null,
    val survivors: List<Survivor>? = null,
    val tasks: List<String>? = null,    
    val missions: List<String>? = null, 
    val bountyCap: Int? = null,
    val bountyCapTimestamp: Long? = null,
    val research: Map<String, Int>? = null,
) {
    companion object {
        fun admin(): PlayerLoginState {
            return PlayerLoginState(
                invsize = 3000
            )
        }

    }
}
