package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
data class AllianceTask(
    val id: String,
    val imageURI: String,
    val iconType: String,
    val goalType: String,
    val goalId: String,
    val goalPerMember: Int,
    val tokensPerMember: Int
)
