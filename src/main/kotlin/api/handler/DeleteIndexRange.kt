package api.handler

import api.message.db.DeleteObjectsOutput
import api.protocol.pioFraming
import context.ServerContext
import common.logInput
import io.ktor.http.HttpStatusCode
import io.ktor.server.request.receiveChannel
import io.ktor.server.response.respond
import io.ktor.server.response.respondBytes
import io.ktor.server.routing.RoutingContext
import io.ktor.utils.io.toByteArray
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.protobuf.ProtoBuf
import kotlinx.serialization.encodeToByteArray

/**
 * Delete objects within an index range
 * Endpoint 100
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.deleteIndexRange(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    // TODO: Parse DeleteIndexRangeArgs and implement deletion logic
    logInput("DeleteIndexRange", disableLogging = true)

    // Return success
    val output = DeleteObjectsOutput(success = true)
    val encoded = ProtoBuf.encodeToByteArray(output)
    call.respondBytes(encoded.pioFraming())
}
