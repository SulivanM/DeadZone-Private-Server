package dev.deadzone.api.message.social

import dev.deadzone.api.message.utils.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class PlayerInsightState(
    val playersOnline: Int = 0,
    val segments: List<KeyValuePair> = emptyList()
)
