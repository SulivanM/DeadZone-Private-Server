package dev.deadzone.api.handler
import dev.deadzone.api.message.db.LoadIndexRangeArgs
import dev.deadzone.api.message.db.LoadObjectsOutput
import dev.deadzone.api.utils.pioFraming
import dev.deadzone.utils.logInput
import io.ktor.server.request.receiveChannel
import io.ktor.server.response.respondBytes
import io.ktor.server.routing.RoutingContext
import io.ktor.utils.io.toByteArray
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.loadIndexRange() {
    val args = ProtoBuf.decodeFromByteArray<LoadIndexRangeArgs>(
        call.receiveChannel().toByteArray()
    )
    logInput(args)
    val outputBytes = ProtoBuf.encodeToByteArray(
        LoadObjectsOutput(objects = emptyList())
    )
    call.respondBytes(outputBytes.pioFraming())
}