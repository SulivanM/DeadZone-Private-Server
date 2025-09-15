package dev.deadzone.api.message.client

import dev.deadzone.api.message.utils.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class CreateJoinRoomArgs(
    val roomId: String = "",
    val roomType: String = "",
    val visible: Boolean = false,
    val roomData: KeyValuePair = KeyValuePair(),
    val joinData: KeyValuePair = KeyValuePair(),
    val isDevRoom: Boolean = false,
)
