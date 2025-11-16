package api.handler

import api.message.db.LoadMatchingObjectsArgs
import api.message.db.LoadObjectsOutput
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
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.protobuf.ProtoBuf
import kotlinx.serialization.encodeToByteArray

/**
 * Load objects matching a specific index value
 * Endpoint 94
 */
@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.loadMatchingObjects(serverContext: ServerContext) {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<LoadMatchingObjectsArgs>(body)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = true)

    // Handle different table queries
    val objects = when (args.table) {
        "PlayerObjects" -> {
            // Query PlayerObjects by index
            if (args.index == "playerId" && args.indexValue.isNotEmpty()) {
                val playerId = args.indexValue.firstOrNull()?.string ?: ""
                val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                if (playerObjects != null) {
                    listOf(LoadObjectsOutput.fromData(playerObjects))
                } else {
                    emptyList()
                }
            } else {
                emptyList()
            }
        }
        "Inventory" -> {
            // Query Inventory by index
            if (args.index == "playerId" && args.indexValue.isNotEmpty()) {
                val playerId = args.indexValue.firstOrNull()?.string ?: ""
                val inventory = serverContext.db.loadInventory(playerId)
                if (inventory != null) {
                    listOf(LoadObjectsOutput.fromData(inventory))
                } else {
                    emptyList()
                }
            } else {
                emptyList()
            }
        }
        "NeighborHistory" -> {
            // Query NeighborHistory by index
            if (args.index == "playerId" && args.indexValue.isNotEmpty()) {
                val playerId = args.indexValue.firstOrNull()?.string ?: ""
                val neighborHistory = serverContext.db.loadNeighborHistory(playerId)
                if (neighborHistory != null) {
                    listOf(LoadObjectsOutput.fromData(neighborHistory))
                } else {
                    emptyList()
                }
            } else {
                emptyList()
            }
        }
        else -> emptyList()
    }

    val output = LoadObjectsOutput(objects = objects.take(if (args.limit > 0) args.limit else Int.MAX_VALUE))
    val encoded = ProtoBuf.encodeToByteArray(output)
    call.respondBytes(encoded.pioFraming())
}
