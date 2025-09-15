package dev.deadzone.api.handler

import dev.deadzone.api.message.client.CreateJoinRoomArgs
import dev.deadzone.api.message.client.CreateJoinRoomOutput
import dev.deadzone.api.utils.pioFraming
import dev.deadzone.utils.logInput
import dev.deadzone.utils.logOutput
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

/**
 * CreateJoinRoom (API 27)
 *
 * Input: `CreateJoinRoomArgs`
 *
 * Output: `CreateJoinRoomOutput`
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.createJoinRoom() {
    val createJoinRoomArgs = ProtoBuf.decodeFromByteArray<CreateJoinRoomArgs>(
        call.receiveChannel().toByteArray()
    )

    logInput(createJoinRoomArgs)

    val createJoinRoomOutput = ProtoBuf.encodeToByteArray<CreateJoinRoomOutput>(
        CreateJoinRoomOutput.defaultRoom()
    )

    logOutput(createJoinRoomOutput)

    call.respondBytes(createJoinRoomOutput.pioFraming())
}
