package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.core.items.model.Item
import dev.deadzone.utils.UUID

@Serializable
data class JunkBuilding(
    // from Building
    val id: String = UUID.new(),
    val name: String? = null,
    val type: String,
    val level: Int = 0,
    val rotation: Int = 0,
    val tx: Int = 0,
    val ty: Int = 0,
    val destroyed: Boolean = false,
    val resourceValue: Double = 0.0,
    val upgrade: TimerData? = null,
    val repair: TimerData? = null,

    // JunkBuilding-specific fields
    val items: List<Item> = emptyList(),
    val pos: String,
    val rot: String
) : BuildingLike()
