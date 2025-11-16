package api.message.server

import kotlinx.serialization.Serializable

@Serializable
data class ListRoomsOutput(
    val rooms: List<RoomInfoMessage> = emptyList(),
)
