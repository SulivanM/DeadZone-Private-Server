package dev.deadzone.core.model.game.data.store

import kotlinx.serialization.Serializable
import dev.deadzone.core.items.model.Item

@Serializable
data class StoreItem(
    val key: String,
    val item: Item,
    val new: Boolean,
    val deal: Boolean,
    val promo: Boolean,
    val collectionOnly: Boolean,
    val admin: Boolean,
    val sale: String?,
    val priority: Int,
    val levelMin: Int = 0,
    val levelMax: Int = 2147483647,
    val start: Long?,
    val end: Long?,
    val PriceCoins: Int?,  // pricecoins else usd or kkr
    val priceUSD: Double?,
    val priceKKR: Int?,
    val orgPriceFUEL: Int?,
    val orgPriceUSD: Int?,
    val orgPriceKKR: Int?,
    val showOrgPrice: Boolean
)
