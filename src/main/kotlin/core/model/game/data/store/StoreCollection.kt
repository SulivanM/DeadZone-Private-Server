package dev.deadzone.core.model.game.data.store

import kotlinx.serialization.Serializable

@Serializable
data class StoreCollection(
    val key: String,
    val admin: Boolean = false,
    val new: Boolean = false,
    val individualPurchases: Boolean = true,
    val levelMin: Int = 0,
    val levelMax: Int = 2147483647,
    val start: Long?,
    val end: Long?,
    val items: List<String> = listOf(),
    val PriceCoins: Int = 0,
    val PriceUSD: Int = 0,
    val PriceKKR: Int = 0
)
