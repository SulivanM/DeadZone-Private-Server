package core.model.game.data

import kotlinx.serialization.Serializable
import core.items.model.Item

@Serializable
data class EnemyResults(
    val attackerId: String,
    val attackerNickname: String,
    val numSrvDown: Int = 0,
    val survivors: List<String> = listOf(),
    val srvDown: List<String> = listOf(),
    val loot: List<Item> = listOf(),
    val prodBuildingsRaided: List<String> = listOf(),
    val buildingsDestroyed: List<String> = listOf(),
    val trapsTriggered: List<String> = listOf(),
    val trapsDisarmed: List<String> = listOf(),
    val totalBuildingsLooted: Int?
)
