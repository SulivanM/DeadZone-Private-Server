package api.routes

import server.broadcast.BroadcastMessage
import server.broadcast.BroadcastProtocol
import server.broadcast.BroadcastService
import context.ServerContext
import io.ktor.http.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.serialization.Serializable
import common.Logger

@Serializable
data class BroadcastRequest(
    val protocol: String,
    val arguments: List<String> = emptyList()
)

@Serializable
data class BroadcastResponse(
    val success: Boolean,
    val message: String,
    val clientCount: Int = 0
)

fun Route.broadcastRoutes(context: ServerContext) {
    route("/api/broadcast") {
        // Get broadcast status
        get("/status") {
            call.respond(
                HttpStatusCode.OK,
                mapOf(
                    "enabled" to BroadcastService.isEnabled(),
                    "clientCount" to BroadcastService.getClientCount()
                )
            )
        }

        // Send a broadcast message (admin only in production)
        post("/send") {
            if (context.config.isProd && !context.config.adminEnabled) {
                call.respond(HttpStatusCode.Forbidden, BroadcastResponse(false, "Broadcast API is disabled in production"))
                return@post
            }

            try {
                val request = call.receive<BroadcastRequest>()
                val protocol = BroadcastProtocol.fromCode(request.protocol)

                if (protocol == null) {
                    call.respond(
                        HttpStatusCode.BadRequest,
                        BroadcastResponse(false, "Invalid protocol: ${request.protocol}")
                    )
                    return@post
                }

                val message = BroadcastMessage(protocol, request.arguments)
                BroadcastService.broadcast(message)

                Logger.info("📤 Broadcast sent via API: ${message.toWireFormat()}")

                call.respond(
                    HttpStatusCode.OK,
                    BroadcastResponse(
                        success = true,
                        message = "Broadcast sent successfully",
                        clientCount = BroadcastService.getClientCount()
                    )
                )
            } catch (e: Exception) {
                Logger.error("Failed to send broadcast: ${e.message}")
                call.respond(
                    HttpStatusCode.InternalServerError,
                    BroadcastResponse(false, "Failed to send broadcast: ${e.message}")
                )
            }
        }

        // Quick test endpoint for plain text
        post("/test") {
            if (context.config.isProd && !context.config.adminEnabled) {
                call.respond(HttpStatusCode.Forbidden, BroadcastResponse(false, "Broadcast API is disabled in production"))
                return@post
            }

            @Serializable
            data class TestRequest(val message: String)

            try {
                val request = call.receive<TestRequest>()
                BroadcastService.broadcastPlainText(request.message)

                Logger.info("📤 Test broadcast sent: ${request.message}")

                call.respond(
                    HttpStatusCode.OK,
                    BroadcastResponse(
                        success = true,
                        message = "Test broadcast sent",
                        clientCount = BroadcastService.getClientCount()
                    )
                )
            } catch (e: Exception) {
                Logger.error("Failed to send test broadcast: ${e.message}")
                call.respond(
                    HttpStatusCode.InternalServerError,
                    BroadcastResponse(false, "Failed to send test broadcast: ${e.message}")
                )
            }
        }
    }
}
