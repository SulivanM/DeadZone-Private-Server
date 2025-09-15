package dev.deadzone.core.items.model

import kotlinx.serialization.Serializable
import dev.deadzone.socket.handler.save.crate.response.gachaPoolExample

@Serializable
data class CrateItem(
    val type: String,
    val id: String = "",  // uses GUID.create() by default
    val new: Boolean = false,
    val storeId: String = "",
    val level: Int = 0,
    val series: Int = 0,
    val version: Int = 0,
    val contents: List<Item> = gachaPoolExample
)
