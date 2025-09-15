package dev.deadzone.api.routes

import io.ktor.http.*
import io.ktor.server.http.content.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.io.File

fun Route.fileRoutes() {
    get("/") {
        val indexFile = File("static/index.html")
        if (indexFile.exists()) {
            call.respondFile(indexFile)
        } else {
            call.respond(HttpStatusCode.NotFound)
        }
    }

    staticFiles("/game", File("static/game/"))
    staticFiles("/assets", File("static/assets"))
    staticFiles("/crossdomain.xml", File("static/crossdomain.xml"))
}
