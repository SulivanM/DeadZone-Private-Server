package api.message.server

import api.message.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class ListRoomsArgs(
    val roomType: String = "",
    val searchCriteria: List<KeyValuePair> = emptyList(),
    val resultLimit: Int = 0,
    val resultOffset: Int = 0,
    val onlyDevRooms: Boolean = false,
)
