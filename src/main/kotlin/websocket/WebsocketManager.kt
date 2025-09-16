package dev.deadzone.websocket

import io.ktor.server.websocket.DefaultWebSocketServerSession
import io.ktor.websocket.Frame
import kotlinx.serialization.json.Json
import java.util.concurrent.ConcurrentHashMap

typealias ClientSessions = ConcurrentHashMap<String, DefaultWebSocketServerSession>

class WebsocketManager() {
    private val connectedDebugClients = ClientSessions()
    private var resourceLoadCompleted: Boolean = false

    fun addClient(clientId: String, session: DefaultWebSocketServerSession) {
        connectedDebugClients[clientId] = session
    }

    fun removeClient(clientId: String): Boolean {
        return connectedDebugClients.remove(clientId) != null
    }

    fun getAllClients(): ClientSessions {
        return connectedDebugClients
    }

    suspend fun onResourceLoadComplete() {
        resourceLoadCompleted = true
        connectedDebugClients.values.forEach {
            it.send(Frame.Text(Json.encodeToString(WsMessage(type = "ready", payload = null))))
        }
    }

    suspend fun handleMessage(session: DefaultWebSocketServerSession, message: WsMessage) {
        when (message.type) {
            "isready" -> {
                val response = if (resourceLoadCompleted) "ready" else "notready"
                session.send(Frame.Text(Json.encodeToString(WsMessage(type = response, payload = null))))
            }
        }
    }
}
