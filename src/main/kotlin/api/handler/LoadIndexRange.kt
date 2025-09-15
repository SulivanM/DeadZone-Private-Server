package dev.deadzone.api.handler

import dev.deadzone.api.message.db.LoadIndexRangeArgs
import dev.deadzone.api.message.db.LoadObjectsOutput
import dev.deadzone.api.utils.pioFraming
import dev.deadzone.context.ServerContext
import dev.deadzone.utils.logInput
import io.ktor.server.request.receiveChannel
import io.ktor.server.response.respondBytes
import io.ktor.server.routing.RoutingContext
import io.ktor.utils.io.toByteArray
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

/**
 * LoadIndexRange (API 97)
 *
 * Input: [LoadIndexRangeArgs]
 * Output: [LoadObjectsOutput] (list of BigDBObject)
 *
 * NOTE:
 * - This minimal implementation returns an empty list.
 * - Hook up to your DB/indexing once ready, using args.table/index/start/stop/limit.
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.loadIndexRange(serverContext: ServerContext) {
    val args = ProtoBuf.decodeFromByteArray<LoadIndexRangeArgs>(
        call.receiveChannel().toByteArray()
    )

    // Optional: log input for diagnostics
    logInput(args)

    // TODO: Implement actual index range lookup using your DB once available.
    val outputBytes = ProtoBuf.encodeToByteArray(
        LoadObjectsOutput(objects = emptyList())
    )

    call.respondBytes(outputBytes.pioFraming())
}
