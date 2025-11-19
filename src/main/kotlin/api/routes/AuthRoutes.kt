package api.routes

import context.ServerContext
import core.data.AdminData
import common.Logger
import io.ktor.http.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Route.authRoutes(serverContext: ServerContext) {

    post("/api/login") {
        val data = call.receive<Map<String, String?>>()
        val username = data["username"]
        val password = data["password"]
        val email = data["email"]
        val countryCode = data["countryCode"]

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
            val session = serverContext.authProvider.register(username, password, email, countryCode)
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

    post("/api/update-user-info") {
        val data = call.receive<Map<String, String?>>()
        val username = data["username"]
        val email = data["email"]
        val countryCode = data["countryCode"]

        if (username.isNullOrBlank()) {
            call.respond(HttpStatusCode.BadRequest, mapOf("reason" to "Missing username"))
            return@post
        }

        try {
            val userDocResult = serverContext.playerAccountRepository.getUserDocByUsername(username)
            userDocResult.onFailure {
                Logger.error { "Failed to get user doc for username=$username: ${it.message}" }
                call.respond(HttpStatusCode.InternalServerError, mapOf("reason" to "Database error"))
                return@post
            }

            val userDoc = userDocResult.getOrNull()
            if (userDoc == null) {
                call.respond(HttpStatusCode.NotFound, mapOf("reason" to "User not found"))
                return@post
            }

            // Update user account with new email and/or country code
            val updatedAccount = userDoc.copy(
                email = email ?: userDoc.email,
                countryCode = countryCode ?: userDoc.countryCode
            )

            val updateResult = serverContext.playerAccountRepository.updatePlayerAccount(userDoc.playerId, updatedAccount)
            updateResult.onFailure {
                Logger.error { "Failed to update user info for username=$username: ${it.message}" }
                call.respond(HttpStatusCode.InternalServerError, mapOf("reason" to "Failed to update user info"))
                return@post
            }

            call.respond(HttpStatusCode.OK, mapOf("success" to "true", "message" to "User info updated successfully"))
        } catch (e: Exception) {
            Logger.error { "Unexpected error updating user info for username=$username: ${e.message}" }
            call.respond(HttpStatusCode.InternalServerError, mapOf("reason" to "Unexpected error"))
        }
    }
}
