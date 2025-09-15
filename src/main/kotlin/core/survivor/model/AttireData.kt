package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.AttireOverlay

@Serializable
data class AttireData(
    val id: String = "",
    val type: String = "",
    val model: String = "",
    val texture: String = "",
    val tint: Double = 0.0,
    val hue: Double = 0.0,
    val brightness: Double = 0.0,
    val modifiedTextureURI: String = "",
    val modifiedTexture: Boolean = false,
    val uniqueTexture: Boolean = false,
    val overlays: List<AttireOverlay> = listOf(),
    val children: List<AttireData> = listOf(),
    val flags: Int = 0
)
