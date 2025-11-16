package api.handler

import api.message.server.ListRoomsArgs
import api.message.server.ListRoomsOutput
import api.message.server.RoomInfoMessage
import api.message.toKeyValuePairList
import api.message.toMap
import api.protocol.pioFraming
import common.Logger
import common.logInput
import common.logOutput
import io.ktor.http.HttpStatusCode
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf
import room.RoomManager
import room.RoomType

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.listRooms() {
    val body = try {
        call.receiveChannel().toByteArray()
    } catch (e: Exception) {
        Logger.error { "ListRooms - Failed to receive body: ${e.message}" }
        call.respond(HttpStatusCode.BadRequest, "invalid_body")
        return
    }

    val args = try {
        ProtoBuf.decodeFromByteArray<ListRoomsArgs>(body)
    } catch (e: Exception) {
        Logger.error { "ListRooms - Failed to decode args: ${e.message}" }
        call.respond(HttpStatusCode.BadRequest, "invalid_payload")
        return
    }

    logInput(args, disableLogging = true)

    Logger.debug { "ListRooms - roomType: ${args.roomType}, limit: ${args.resultLimit}, offset: ${args.resultOffset}, onlyDevRooms: ${args.onlyDevRooms}" }

    // Déterminer le type de room
    val roomType = RoomType.fromTypeName(args.roomType) ?: run {
        Logger.error { "ListRooms - Invalid room type: ${args.roomType}" }
        call.respond(HttpStatusCode.BadRequest, "invalid_room_type")
        return
    }

    // Récupérer les rooms du type spécifié
    var roomsList = RoomManager.listRoomsByType(
        roomType = roomType,
        visibleOnly = true,
        devRoomsOnly = args.onlyDevRooms
    )

    // Appliquer les critères de recherche si fournis
    if (args.searchCriteria.isNotEmpty()) {
        val searchMap = args.searchCriteria.toMap()
        Logger.debug { "ListRooms - Search criteria: $searchMap" }

        roomsList = roomsList.filter { roomInfo ->
            // Vérifier que toutes les paires clé-valeur de recherche correspondent
            searchMap.all { (key, value) ->
                roomInfo.roomData[key]?.toString() == value.toString()
            }
        }
    }

    // Appliquer la pagination
    val totalRooms = roomsList.size
    val offset = args.resultOffset.coerceAtLeast(0)
    val limit = if (args.resultLimit > 0) args.resultLimit else totalRooms

    roomsList = roomsList.drop(offset).take(limit)

    Logger.debug { "ListRooms - Found ${roomsList.size} rooms (total: $totalRooms, offset: $offset, limit: $limit)" }

    // Convertir les RoomInfo en RoomInfoMessage
    val roomMessages = roomsList.map { roomInfo ->
        RoomInfoMessage(
            id = roomInfo.id,
            roomType = roomInfo.roomType,
            onlineUsers = roomInfo.onlineUsers,
            roomData = roomInfo.roomData.toKeyValuePairList()
        )
    }

    // Créer la réponse
    val output = ListRoomsOutput(
        rooms = roomMessages
    )

    val outputBytes = try {
        ProtoBuf.encodeToByteArray(output)
    } catch (e: Exception) {
        Logger.error { "ListRooms - Failed to encode output: ${e.message}" }
        call.respond(HttpStatusCode.InternalServerError, "encode_error")
        return
    }

    logOutput(outputBytes, disableLogging = true)

    call.respondBytes(outputBytes.pioFraming())
}
