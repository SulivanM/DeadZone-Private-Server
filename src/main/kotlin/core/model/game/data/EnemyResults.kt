package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.core.items.model.Item

@Serializable
data class EnemyResults(
    val attackerId: String,
    val attackerNickname: String,
    val numSrvDown: Int = 0,
    val survivors: List<String> = listOf(),  // survivor ids
    val srvDown: List<String> = listOf(),  // survivor ids
    val loot: List<Item> = listOf(),
    val prodBuildingsRaided: List<String> = listOf(),  // building ids
    val buildingsDestroyed: List<String> = listOf(),  // building ids
    val trapsTriggered: List<String> = listOf(),  // building ids
    val trapsDisarmed: List<String> = listOf(),  // building ids
    val totalBuildingsLooted: Int?
)
