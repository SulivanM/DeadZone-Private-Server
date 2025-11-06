package api.handler

import api.message.server.CreateJoinRoomArgs
import api.message.server.CreateJoinRoomOutput
import api.message.server.ServerEndpoint
import api.utils.pioFraming
import context.ServerContext
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
suspend fun RoutingContext.createJoinRoom(serverContext: ServerContext, playerToken: String) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<CreateJoinRoomArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = false)

    val playerId = serverContext.sessionManager.getPlayerId(playerToken)
    if (playerId.isNullOrBlank()) {
        call.respond(HttpStatusCode.Unauthorized, "Invalid player token")
        return
    }

    val roomId = args.roomId
    val actualRoomId = if (roomId.startsWith("A_")) {
        val requestedAllianceId = roomId.removePrefix("A_")
        val recentlyCreatedAllianceId = serverContext.allianceCreationTracker.getRecentlyCreated(playerId)

        if (recentlyCreatedAllianceId != null && recentlyCreatedAllianceId != requestedAllianceId) {

            utils.Logger.info { "Redirecting player $playerId from alliance $requestedAllianceId to $recentlyCreatedAllianceId" }
            "A_$recentlyCreatedAllianceId"
        } else {
            roomId
        }
    } else {
        roomId
    }

    val joinKey = serverContext.joinKeyManager.create(playerId)

    val output = CreateJoinRoomOutput(
        roomId = actualRoomId,
        joinKey = joinKey,
        endpoints = ServerEndpoint.socketServer()
    )


    val outputBytes = try {
        ProtoBuf.encodeToByteArray(output)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.InternalServerError, "encode_error")
        return
    }

    logOutput(outputBytes, disableLogging = false)

    call.respondBytes(outputBytes.pioFraming())
}
