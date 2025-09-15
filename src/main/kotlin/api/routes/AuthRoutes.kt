package dev.deadzone.api.routes

import dev.deadzone.context.ServerContext
import dev.deadzone.core.data.AdminData
import dev.deadzone.utils.Logger
import io.ktor.http.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.authRoutes(serverContext: ServerContext) {
    post("/api/login") {
        val data = call.receive<Map<String, String>>()
        val username = data["username"]
        val password = data["password"]

        if (username == null || password == null) {
            call.respond(HttpStatusCode.BadRequest, mapOf("reason" to "Missing credentials"))
            return@post
        }

        if (username == AdminData.ADMIN_RESERVED_NAME) {
            if (serverContext.config.adminEnabled) {
                val session = serverContext.authProvider.adminLogin()
                if (session != null) {
                    call.respond(HttpStatusCode.OK, mapOf("playerId" to session.playerId, "token" to session.token))
                } else {
                    call.respond(
                        HttpStatusCode.InternalServerError,
                        mapOf("reason" to "unexpected error: admin account doesn't exist")
                    )
                }
            } else {
                call.respond(HttpStatusCode.Forbidden, mapOf("reason" to "admin account not enabled"))
            }
            return@post
        }

        val usernameExist = serverContext.authProvider.doesUserExist(username)
        if (usernameExist) {
            val loginSession = serverContext.authProvider.login(username, password)
            val passwordRight = loginSession != null
            if (passwordRight) {
                call.respond(
                    HttpStatusCode.OK,
                    mapOf("playerId" to loginSession.playerId, "token" to loginSession.token)
                )
            } else {
                call.respond(
                    HttpStatusCode.Unauthorized,
                    mapOf("reason" to "wrong password")
                )
            }
        } else {
            val session = serverContext.authProvider.register(username, password)
            call.respond(
                HttpStatusCode.OK,
                mapOf("playerId" to session.playerId, "token" to session.token)
            )
        }
    }

    get("/api/userexist") {
        val username = call.parameters["username"]
        if (username.isNullOrBlank()) {
            call.respondText("no", status = HttpStatusCode.BadRequest)
            return@get
        }

        if (username == AdminData.ADMIN_RESERVED_NAME) {
            if (serverContext.config.adminEnabled) {
                call.respondText("granted")
            } else {
                call.respondText("reserved")
            }
            return@get
        }

        try {
            val exists = serverContext.authProvider.doesUserExist(username)
            call.respondText(if (exists) "yes" else "no")
        } catch (e: Exception) {
            Logger.error { "Failed to check if user exists: $username, e.message:${e.message}" }
            call.respond(HttpStatusCode.InternalServerError, mapOf("reason" to "Database error"))
        }
    }

    get("/keepalive") {
        val token = call.parameters["token"] ?: return@get call.respond(HttpStatusCode.BadRequest, "missing token")
        if (serverContext.sessionManager.refresh(token)) {
            return@get call.respond(HttpStatusCode.OK)
        } else {
            return@get call.respond(HttpStatusCode.Unauthorized, "Session expired, please login again")
        }
    }
}
