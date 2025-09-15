package dev.deadzone.api.handler

import dev.deadzone.api.message.db.LoadObjectsOutput
import dev.deadzone.api.message.utils.WriteErrorArgs
import dev.deadzone.api.message.utils.WriteErrorError
import dev.deadzone.api.utils.pioFraming
import dev.deadzone.utils.*
import io.ktor.http.HttpStatusCode
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

/**
 * WriteError (API 50)
 *
 * Input: `WriteErrorArgs`
 *
 * Output: `WriteErrorError` (optional)
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.writeError() {
    val writeErrorArgs = ProtoBuf.decodeFromByteArray<WriteErrorArgs>(
        call.receiveChannel().toByteArray()
    )

    logInput("\n" + writeErrorArgs)

    Logger.error(LogConfigWriteError) { writeErrorArgs.toString() }

    if (writeErrorArgs.details.contains("Load Never Completed", ignoreCase = true) ||
        writeErrorArgs.details.contains("Resource not found", ignoreCase = true) ||
        writeErrorArgs.details.contains("Resource load fail", ignoreCase = true) ||
        writeErrorArgs.details.contains("2036", ignoreCase = true) ||
        writeErrorArgs.details.contains("Stream error", ignoreCase = true)
    ) {
        Logger.error(LogConfigAssetsError) { writeErrorArgs.details }
    }

    val loadObjectsOutput = ProtoBuf.encodeToByteArray(WriteErrorError.dummy())

//    logOutput(loadObjectsOutput)

    call.respondBytes(loadObjectsOutput.pioFraming())
}
