package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.core.items.model.Item

@Serializable
data class SurvivorLoadoutData(
    val type: String,
    val item: Item,
    val quantity: Int,
    val loadout: SurvivorLoadout
)
