package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class GameResourcesConstants(val value: String)

object GameResourcesConstants_Constants {
    val CASH = GameResourcesConstants("cash")
    val WOOD = GameResourcesConstants("wood")
    val METAL = GameResourcesConstants("metal")
    val CLOTH = GameResourcesConstants("cloth")
    val WATER = GameResourcesConstants("water")
    val FOOD = GameResourcesConstants("food")
    val AMMUNITION = GameResourcesConstants("ammunition")
}
