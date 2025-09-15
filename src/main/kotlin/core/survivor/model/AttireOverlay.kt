package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class AttireOverlay(
    val type: String,
    val texture: String
)
