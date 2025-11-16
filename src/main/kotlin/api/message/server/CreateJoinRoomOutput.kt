package api.message.server

import kotlinx.serialization.Serializable

@Serializable
data class CreateJoinRoomOutput(
    val roomId: String = "",
    val joinKey: String = "",
    val endpoints: List<ServerEndpoint> = emptyList(),
) {
    companion object {
        fun defaultRoom(): CreateJoinRoomOutput {
            return CreateJoinRoomOutput(
                roomId = "defaultRoomId",
                joinKey = "defaultJoinKey",
                endpoints = listOf(ServerEndpoint.socketServer())
            )
        }
    }
}
