package api.message.server

import api.message.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class CreateJoinRoomArgs(
    val roomId: String = "",
    val roomType: String = "",
    val visible: Boolean = false,
    val roomData: List<KeyValuePair> = emptyList(),
    val joinData: List<KeyValuePair> = emptyList(),
    val isDevRoom: Boolean = false,
)
