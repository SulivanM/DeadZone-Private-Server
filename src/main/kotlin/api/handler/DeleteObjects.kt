package api.handler

import api.message.db.*
import api.protocol.pioFraming
import context.ServerContext
import common.LogConfigAPIError
import common.Logger
import common.logInput
import common.logOutput
import io.ktor.http.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.deleteObjects(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val deleteObjectsArgs = try {
        ProtoBuf.decodeFromByteArray<DeleteObjectsArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(deleteObjectsArgs, disableLogging = false)

    for (objId in deleteObjectsArgs.objectIds) {
        try {
            serverContext.db.deleteObjects(
                table = objId.table,
                keys = objId.keys
            )
        } catch (e: Exception) {
            Logger.error(LogConfigAPIError) { "Failed to delete objects from ${objId.table}: ${e.message}" }
        }
    }

    val output = DeleteObjectsOutput(success = true)
    val encoded = ProtoBuf.encodeToByteArray(output)
    logOutput(encoded, disableLogging = false)
    call.respondBytes(encoded.pioFraming())
}
