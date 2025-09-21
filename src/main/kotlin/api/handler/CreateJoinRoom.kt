package api.handler
import api.message.server.CreateJoinRoomArgs
import api.message.server.CreateJoinRoomOutput
import api.utils.pioFraming
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