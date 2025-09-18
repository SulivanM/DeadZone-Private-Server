package api.message.server

import kotlinx.serialization.Serializable

@Serializable
data class CreateJoinRoomOutput(
    val roomId: String = "",
    val joinKey: String = "",
    val endpoints: ServerEndpoint,
) {
    companion object {
        fun defaultRoom(): CreateJoinRoomOutput {
            return CreateJoinRoomOutput(
                roomId = "defaultRoomId",
                joinKey = "defaultJoinKey",
                endpoints = ServerEndpoint.socketServer()
            )
        }
    }
}
