package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class GameResources(
    val wood: Int = 0,
    val metal: Int = 0,
    val cloth: Int = 0,
    val water: Int = 0,
    val food: Int = 0,
    val ammunition: Int = 0,
    val cash: Int = 0
)

fun GameResources.getNonEmptyResAmountOrNull(): Int? {
    val nonEmpty = listOf(
        wood, metal, cloth, food, water, ammunition, cash
    ).filter { it != 0 }

    return if (nonEmpty.size == 1) nonEmpty.first() else null
}

fun GameResources.getNonEmptyResTypeOrNull(): String? {
    val nonEmpty = listOf(
        "wood" to wood,
        "metal" to metal,
        "cloth" to cloth,
        "food" to food,
        "water" to water,
        "ammunition" to ammunition,
        "cash" to cash
    ).filter { it.second != 0 }

    return nonEmpty.singleOrNull()?.first
}
