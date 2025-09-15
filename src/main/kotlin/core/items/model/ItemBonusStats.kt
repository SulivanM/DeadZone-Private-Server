package dev.deadzone.core.items.model

import kotlinx.serialization.Serializable

@Serializable
data class ItemBonusStats(
    val stat_srv: Map<String, Double>? = null,
    val stat_weap: Map<String, Double>? = null,
    val stat_gear: Map<String, Double>? = null
)
