package api.handler
import api.message.utils.WriteErrorArgs
import api.message.utils.WriteErrorError
import api.utils.pioFraming
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf
import utils.LogConfigAssetsError
import utils.LogConfigWriteError
import utils.Logger
import utils.logInput

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
    call.respondBytes(loadObjectsOutput.pioFraming())
}