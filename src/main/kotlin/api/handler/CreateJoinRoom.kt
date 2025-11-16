package api.handler

import api.message.server.CreateJoinRoomArgs
import api.message.server.CreateJoinRoomOutput
import api.message.toMap
import api.protocol.pioFraming
import context.ServerContext
import io.ktor.http.HttpStatusCode
import common.logInput
import common.logOutput
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.utils.io.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromByteArray
import kotlinx.serialization.encodeToByteArray
import kotlinx.serialization.protobuf.ProtoBuf

@OptIn(ExperimentalSerializationApi::class)
suspend fun RoutingContext.createJoinRoom(serverContext: ServerContext) {
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

    logInput(args, disableLogging = true)

    // Déterminer le type de room
    val roomType = room.RoomType.fromTypeName(args.roomType) ?: run {
        call.respond(HttpStatusCode.BadRequest, "invalid_room_type")
        return
    }

    // Convertir les listes en maps pour faciliter l'accès
    val roomDataMap = args.roomData.toMap()
    val joinDataMap = args.joinData.toMap().toMutableMap()

    // Pour les rooms ALLIANCE, TRADE et autres qui nécessitent l'authentification du joueur,
    // ajouter le serviceUserId au joinData pour que le JoinHandler puisse identifier le joueur
    if (roomType == room.RoomType.ALLIANCE || roomType == room.RoomType.TRADE) {
        val playerId = getPlayerIdFromToken(serverContext)
        if (playerId != null) {
            joinDataMap["serviceUserId"] = playerId
            common.Logger.debug { "CreateJoinRoom - Added serviceUserId to joinData: $playerId" }
        } else {
            common.Logger.warn { "CreateJoinRoom - Could not extract playerId from token for ${args.roomType} room" }
        }
    }

    // Debug logging
    common.Logger.debug { "CreateJoinRoom - roomId: ${args.roomId}, roomType: ${args.roomType}" }
    common.Logger.debug { "CreateJoinRoom - joinData received: $joinDataMap" }
    common.Logger.debug { "CreateJoinRoom - joinData keys: ${joinDataMap.keys}" }

    // Déterminer le channel pour les ChatRooms
    val channel = if (roomType == room.RoomType.CHAT) {
        // Extraire le channel des roomData ou joinData
        val channelName = roomDataMap["channel"] as? String
            ?: joinDataMap["channel"] as? String
            ?: "public"
        room.chat.ChatChannel.fromChannelName(channelName) ?: room.chat.ChatChannel.PUBLIC
    } else {
        null
    }

    // Créer un joinKey
    val joinKey = room.JoinKeyManager.createJoinKey(
        roomId = args.roomId,
        roomType = roomType,
        visible = args.visible,
        roomData = roomDataMap,
        joinData = joinDataMap,
        isDevRoom = args.isDevRoom,
        channel = channel
    )

    // Créer la réponse
    val output = CreateJoinRoomOutput(
        roomId = args.roomId,
        joinKey = joinKey,
        endpoints = listOf(api.message.server.ServerEndpoint.socketServer())
    )

    val outputBytes = try {
        ProtoBuf.encodeToByteArray(output)
    } catch (e: Exception) {
        call.respond(HttpStatusCode.InternalServerError, "encode_error")
        return
    }

    logOutput(outputBytes, disableLogging = true)

    call.respondBytes(outputBytes.pioFraming())
}
