package dev.deadzone.core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
data class AllianceMessage(
    val id: String,
    val date: Long,
    val playerId: String,
    val author: String,
    val title: String,
    val message: String
)
