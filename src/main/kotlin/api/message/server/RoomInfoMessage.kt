package api.message.server

import api.message.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class RoomInfoMessage(
    val id: String = "",
    val roomType: String = "",
    val onlineUsers: Int = 0,
    val roomData: List<KeyValuePair> = emptyList(),
)
