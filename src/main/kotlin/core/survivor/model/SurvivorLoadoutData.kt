package core.model.game.data

import kotlinx.serialization.Serializable
import core.items.model.Item

@Serializable
data class SurvivorLoadoutData(
    val type: String,
    val item: Item,
    val quantity: Int,
    val loadout: SurvivorLoadout
)
