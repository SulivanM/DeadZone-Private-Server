package dev.deadzone.api.routes

import io.ktor.http.ContentType
import io.ktor.http.HttpStatusCode
import io.ktor.http.defaultForFileExtension
import io.ktor.server.request.path
import io.ktor.server.response.respond
import io.ktor.server.response.respondFile
import io.ktor.server.routing.Route
import io.ktor.server.routing.contentType
import io.ktor.server.routing.get
import java.io.File
import kotlin.io.extension

fun Route.caseInsensitiveStaticResources(baseUrl: String, rootFolder: File) {
    val fileMap = scanFileSystemResources(rootFolder)

    get("$baseUrl/{...}") {
        val rawPath = call.request.path().replace(Regex("/+"), "/")
        val relativePath = rawPath.removePrefix(baseUrl).trimStart('/')
        val lookupKey = "$baseUrl/${relativePath}".lowercase()

        val file = fileMap[lookupKey]
        if (file != null && file.exists()) {
            val contentType = ContentType.defaultForFileExtension(file.extension)
            return@get call.respondFile(file, configure = {
                contentType(contentType) {}
            })
        }

        call.respond(HttpStatusCode.NotFound)
    }
}

fun scanFileSystemResources(resourceRoot: File): Map<String, File> {
    val map = mutableMapOf<String, File>()

    resourceRoot.walkTopDown()
        .filter { it.isFile }
        .forEach { file ->
            val relativePath = file.relativeTo(resourceRoot).invariantSeparatorsPath
            val key = ("/$relativePath").lowercase()
            map[key] = file
        }

    return map
}
