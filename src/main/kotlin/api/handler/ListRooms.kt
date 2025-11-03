package api.handler

import api.message.server.ListRoomsArgs
import api.message.server.ListRoomsOutput
import api.utils.pioFraming
import io.ktor.http.HttpStatusCode
import utils.logInput
import utils.logOutput
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.listRooms() {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<ListRoomsArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = true)

    val output = ListRoomsOutput(rooms = emptyList())
    
    val outputBytes = try {
        ProtoBuf.encodeToByteArray(output)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.InternalServerError, "encode_error")
        return
    }

    logOutput(outputBytes, disableLogging = true)

    call.respondBytes(outputBytes.pioFraming())
}
