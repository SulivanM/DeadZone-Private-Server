package core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class AttireOverlay(
    val type: String,
    val texture: String
)
