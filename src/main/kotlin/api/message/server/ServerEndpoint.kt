package dev.deadzone.api.message.server

import dev.deadzone.SERVER_HOST
import dev.deadzone.SOCKET_SERVER_PORT
import kotlinx.serialization.Serializable

@Serializable
data class ServerEndpoint(
    val address: String = "",
    val port: Int = 0,
) {
    companion object {
        fun socketServer(): ServerEndpoint {
            return ServerEndpoint(
                address = SERVER_HOST,
                port = SOCKET_SERVER_PORT
            )
        }
    }
}
