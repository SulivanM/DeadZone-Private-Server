package api.message.social

import api.message.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class PlayerInsightState(
    val playersOnline: Int = 0,
    val segments: List<KeyValuePair> = emptyList()
)
