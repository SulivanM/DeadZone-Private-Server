package dev.deadzone.core.model.game.data.store

import kotlinx.serialization.Serializable

@Serializable
data class StoreSale(
    val admin: Boolean,
    val savingPerc: Double,
    val levelMin: Int = 0,
    val levelMax: Int = 2147483647,
    val start: Long,
    val end: Long,
    val items: List<String>?,  // assigned to itemKeys, a list of string
)
