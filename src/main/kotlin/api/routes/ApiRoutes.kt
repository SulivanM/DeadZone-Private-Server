package api.routes

import api.handler.*
import context.ServerContext
import utils.LogConfigAPIError
import utils.Logger
import io.ktor.http.HttpStatusCode
import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.get
import io.ktor.server.routing.post

fun Route.apiRoutes(serverContext: ServerContext) {
    get("/api/status") {
        call.respond(HttpStatusCode.OK, mapOf("status" to "online"))
    }

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
            "97" -> loadIndexRange()
            else -> {
                Logger.error(LogConfigAPIError) { "Unimplemented API route: $path" }
                call.respond(HttpStatusCode.NotFound, "Unimplemented API: $path")
            }
        }
    }
}
