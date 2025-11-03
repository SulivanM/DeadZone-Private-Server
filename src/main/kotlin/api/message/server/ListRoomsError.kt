package api.message.server

import kotlinx.serialization.Serializable

@Serializable
data class ListRoomsError(
    val errorCode: Int = 0,
    val message: String = "",
)
