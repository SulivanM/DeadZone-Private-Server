package api.message.server

import dev.deadzone.AppConfig
import kotlinx.serialization.Serializable

@Serializable
data class ServerEndpoint(
    val address: String = "",
    val port: Int = 0,
) {
    companion object {
        fun socketServer(): ServerEndpoint {
            return ServerEndpoint(
                address = AppConfig.gameHost,
                port = AppConfig.gamePort
            )
        }
    }
}