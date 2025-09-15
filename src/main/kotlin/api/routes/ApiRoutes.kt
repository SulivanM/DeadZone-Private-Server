package dev.deadzone.api.routes

import dev.deadzone.api.handler.authenticate
import dev.deadzone.api.handler.createJoinRoom
import dev.deadzone.api.handler.loadObjects
import dev.deadzone.api.handler.socialRefresh
import dev.deadzone.api.handler.writeError
import dev.deadzone.context.ServerContext
import dev.deadzone.utils.LogConfigAPIError
import dev.deadzone.utils.Logger
import io.ktor.http.HttpStatusCode
import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.post

fun Route.apiRoutes(serverContext: ServerContext) {
    post("/api/{path}") {
        val path = call.parameters["path"] ?: return@post call.respond(HttpStatusCode.BadRequest)

        val playerToken = if (path != "13" && path != "50") {
            call.request.queryParameters["playertoken"]
                ?: call.request.headers["playertoken"]
                ?: return@post call.respond(HttpStatusCode.Unauthorized, "Missing playertoken")
        } else {
            null
        }

        when (path) {
            "13" -> authenticate(serverContext)
            "601" -> socialRefresh(serverContext, playerToken!!)
            "27" -> createJoinRoom()
            "50" -> writeError()
            "85" -> loadObjects(serverContext)
            else -> {
                Logger.error(LogConfigAPIError) { "Unimplemented API route: $path" }
                call.respond(HttpStatusCode.NotFound, "Unimplemented API: $path")
            }
        }
    }
}
