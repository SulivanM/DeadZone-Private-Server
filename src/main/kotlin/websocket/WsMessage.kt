package dev.deadzone.websocket

import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement

@Serializable
data class WsMessage(
    val type: String,
    val payload: JsonElement? = null,
)
