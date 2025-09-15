package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class AttributeOptions(
    val INCLUDE_NONE: Int = 0,
    val INCLUDE_INJURIES: Int = 1,
    val INCLUDE_MORALE: Int = 2,
    val INCLUDE_AI_EFFECTS: Int = 4,
    val INCLUDE_RESEARCH: Int = 8,
    val INCLUDE_EFFECTS: Int = 16,
    val INCLUDE_ALL: Int = 31,
    val NO_MORALE: Int = 29,
    val NO_INJURY: Int = 30
)
