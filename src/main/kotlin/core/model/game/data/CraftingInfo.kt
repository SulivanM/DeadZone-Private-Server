package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class CraftingInfo(
    val user_id: String,
    val user_name: String,
    val date: Long
)
