package api.message.server

import api.message.utils.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class RoomInfo(
    val id: String = "",
    val roomType: String = "",
    val onlineUsers: Int = 0,
    val roomData: KeyValuePair = KeyValuePair(),
)
