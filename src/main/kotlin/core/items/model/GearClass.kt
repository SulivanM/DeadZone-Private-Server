package dev.deadzone.core.items.model

import kotlinx.serialization.Serializable

@Serializable
data class GearClass(
    val GLOVES: String = "gloves",
    val GLASSES: String = "glasses",
    val SHOES: String = "shoes",
    val VEST: String = "vest",
    val GRENADE: String = "grenade",
    val EXPLOSIVE_CHARGE: String = "expcharge",
    val STIM: String = "stim"
)
