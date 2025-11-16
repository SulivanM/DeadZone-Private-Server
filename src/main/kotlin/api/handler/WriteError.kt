package api.handler

import api.message.WriteErrorArgs
import api.message.WriteErrorError
import api.protocol.pioFraming
import io.ktor.http.HttpStatusCode
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf
import common.LogConfigAssetsError
import common.LogConfigWriteError
import common.Logger
import common.logInput

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.writeError() {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val writeErrorArgs = try {
        ProtoBuf.decodeFromByteArray<WriteErrorArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput("\n$writeErrorArgs", disableLogging = true)

    Logger.error(LogConfigWriteError) { writeErrorArgs.toString() }

    if (writeErrorArgs.details.contains("Load Never Completed", ignoreCase = true) ||
        writeErrorArgs.details.contains("Resource not found", ignoreCase = true) ||
        writeErrorArgs.details.contains("Resource load fail", ignoreCase = true) ||
        writeErrorArgs.details.contains("2036", ignoreCase = true) ||
        writeErrorArgs.details.contains("Stream error", ignoreCase = true)
    ) {
        Logger.error(LogConfigAssetsError) { writeErrorArgs.details }
    }

    val loadObjectsOutput = try {
        ProtoBuf.encodeToByteArray(WriteErrorError.dummy())
    } catch (e: Exception) {
        call.respond(HttpStatusCode.InternalServerError, "encode_error")
        return
    }

    call.respondBytes(loadObjectsOutput.pioFraming())
}