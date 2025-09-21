package api.routes

import io.ktor.http.*
import io.ktor.server.http.content.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.io.File

fun Route.fileRoutes() {
    staticFiles("/game", File("static/game/"))
    staticFiles("/assets", File("static/assets"))
    staticFiles("/crossdomain.xml", File("static/crossdomain.xml"))
}
