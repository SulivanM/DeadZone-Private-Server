package dev.deadzone.core.data

import dev.deadzone.core.model.game.data.GameResources
import dev.deadzone.core.model.game.data.Survivor
import kotlinx.serialization.Serializable

/**
 * Player login state is needed for [dev.deadzone.socket.handler.JoinHandler] result
 *
 * Structure still empty and assumption. See Network.as onGameReady and onPlayerDataLoaded
 */
@Serializable
data class PlayerLoginState(
    // from Network.as onGameReady
    val settings: Map<String, String> = emptyMap(),
    val news: Map<String, String> = emptyMap(), // NewsArticle object
    val sales: List<String> = emptyList(), // assigned to sales category
    val allianceWinnings: Map<String, String> = emptyMap(),
    val recentPVPList: List<String> = emptyList(),

    // From Network.as onPlayerDataLoaded
    val invsize: Int,
    val upgrades: String = "", // base64 encoded string
    val allianceId: String? = null,
    val allianceTag: String? = null,
    val longSession: Boolean = false, // if true: this will prompt captcha question in-game
    val leveledUp: Boolean = false,
    val promos: List<String> = emptyList(),
    val promoSale: String? = null,
    val dealItem: String? = null,
    val leaderResets: Int = 0,
    val unequipItemBinds: List<String> = emptyList(),
    val globalStats: Map<String, List<String>> = mapOf(
        "idList" to emptyList()
    ),

    // from PlayerData.as updateState
    // used to update PlayerData state when user was offline (e.g., depleting water or food)
    val resources: GameResources? = null,
    val survivors: List<Survivor>? = null,
    val tasks: List<String>? = null,    // likely task id
    val missions: List<String>? = null, // likely mission id
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

        fun newgame(): PlayerLoginState {
            return PlayerLoginState(
                invsize = 500
            )
        }
    }
}
