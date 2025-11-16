package api.handler

import api.message.db.LoadIndexRangeArgs
import api.message.db.LoadObjectsOutput
import api.protocol.pioFraming
import context.ServerContext
import common.logInput
import io.ktor.server.request.receiveChannel
import io.ktor.server.response.respondBytes
import io.ktor.server.routing.RoutingContext
import io.ktor.utils.io.toByteArray
import io.ktor.http.HttpStatusCode
import io.ktor.server.response.respond
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.loadIndexRange(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<LoadIndexRangeArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = true)

    // For LoadIndexRange, return empty results as this game doesn't use range queries
    // In a full implementation, would query database for objects within the index range
    // and apply pagination using startIndexValue, stopIndexValue, and limit
    val objects = emptyList<api.message.db.BigDBObject>()

    val outputBytes = try {
        ProtoBuf.encodeToByteArray(
            LoadObjectsOutput(objects = objects)
        )
    } catch (e: Exception) {
        call.respond(HttpStatusCode.InternalServerError, "encode_error")
        return
    }

    call.respondBytes(outputBytes.pioFraming())
}
