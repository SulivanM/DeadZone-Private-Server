package dev.deadzone.api.routes

import dev.deadzone.utils.Logger
import dev.deadzone.websocket.WebsocketManager
import dev.deadzone.websocket.WsMessage
import io.ktor.http.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.websocket.*
import io.ktor.websocket.*
import kotlinx.serialization.json.Json
import java.io.File

fun Route.debugLogRoutes(wsManager: WebsocketManager) {
    get("/debuglog") {
        val file = File("static/debuglog.html")
        if (file.exists()) {
            call.respondFile(file)
        } else {
            call.respond(HttpStatusCode.NotFound, "debuglog.html not found")
        }
    }

    webSocket("/debuglog") {
        val clientId = call.parameters["clientId"]
        if (clientId == null) {
            close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, "Missing clientId"))
            return@webSocket
        }

        wsManager.addClient(clientId, this)

        try {
            for (frame in incoming) {
                if (frame is Frame.Text) {
                    val msg = frame.readText()
                    try {
                        val wsMessage = Json.decodeFromString<WsMessage>(msg)
                        if (wsMessage.type == "close") break
                        wsManager.handleMessage(this, wsMessage)
                    } catch (e: Exception) {
                        Logger.error { "Failed to parse WS message: $msg\n$e" }
                    }
                }
            }
        } catch (e: Exception) {
            Logger.error { "Error in websocket for client $this: $e" }
        } finally {
            wsManager.removeClient(clientId)
            Logger.info { "Client $this disconnected from websocket debug." }
        }
    }
}
