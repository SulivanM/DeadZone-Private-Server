package api.message.server

import api.message.utils.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class ListRoomsArgs(
    val roomType: String = "",
    val searchCriteria: KeyValuePair = KeyValuePair(),
    val resultLimit: Int = 0,
    val resultOffset: Int = 0,
    val onlyDevRooms: Boolean = false,
)
