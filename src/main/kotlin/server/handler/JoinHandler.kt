package server.handler

import context.ServerContext
import core.LoginStateBuilder
import core.data.CostTable
import core.data.SurvivorClassTable
import server.messaging.HandlerContext
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer
import common.Logger
import common.Time
import java.io.ByteArrayOutputStream
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.zip.GZIPOutputStream
import kotlin.time.Duration.Companion.seconds

/**
 * Handle `join` message by:
 *
 * 1. Sending `playerio.joinresult`
 * 2. Sending `gr` message
 */
class JoinHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.getString(NetworkMessage.JOIN) != null
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val joinKey = message.getString(NetworkMessage.JOIN)
        Logger.debug { "Handling join with key: $joinKey" }

        // Consommer le joinKey et récupérer les informations de room
        val joinInfo = room.JoinKeyManager.consumeJoinKey(joinKey ?: "")
        if (joinInfo == null) {
            Logger.error { "Invalid or expired join key: $joinKey" }
            val joinResultMsg = listOf(NetworkMessage.JOIN_RESULT, false)
            send(PIOSerializer.serialize(joinResultMsg), enableLogging = false)
            return
        }

        // Récupérer le userId depuis les joinData stockés dans le JoinKeyManager
        // Si serviceUserId n'est pas présent (par exemple pour les rooms de chat),
        // utiliser le nickName du message socket comme fallback
        val userId = joinInfo.joinData["serviceUserId"] as? String ?: run {
            val nickName = message.getString("nickName")
            if (nickName != null) {
                Logger.warn { "No serviceUserId in joinData, using nickName as userId: $nickName" }
                "guest_$nickName"
            } else {
                // Dernier recours : utiliser le connectionId
                Logger.warn { "No serviceUserId or nickName, using connectionId as userId" }
                "guest_${connection.connectionId}"
            }
        }
        connection.playerId = userId

        Logger.debug { "Join info retrieved: roomId=${joinInfo.roomId}, roomType=${joinInfo.roomType}, userId=$userId" }

        // Créer ou joindre la room
        val roomJoined = room.RoomManager.createOrJoinRoom(
            roomId = joinInfo.roomId,
            roomType = joinInfo.roomType,
            userId = userId,
            connection = connection,
            visible = joinInfo.visible,
            roomData = joinInfo.roomData,
            joinData = joinInfo.joinData,
            isDevRoom = joinInfo.isDevRoom,
            channel = joinInfo.channel,
            serverContext = serverContext
        )

        if (roomJoined == null) {
            Logger.error { "Failed to join room: ${joinInfo.roomId}" }
            val joinResultMsg = listOf(NetworkMessage.JOIN_RESULT, false)
            send(PIOSerializer.serialize(joinResultMsg), enableLogging = false)
            return
        }

        Logger.debug { "Successfully joined room: ${joinInfo.roomId} of type ${joinInfo.roomType}" }

        // First message: join result
        val success = true
        val joinResultMsg = listOf(NetworkMessage.JOIN_RESULT, success)
        send(PIOSerializer.serialize(joinResultMsg), enableLogging = false)
        Logger.debug { "Sent playerio.joinresult:$success to playerId=$userId" }

        // Pour les GAME rooms, créer le PlayerContext et envoyer les données de jeu
        // Pour les CHAT rooms, envoyer initialJoin après joinresult
        if (joinInfo.roomType == room.RoomType.GAME) {
            // Create PlayerContext which initializes per-player services
            serverContext.playerContextTracker.createContext(
                playerId = connection.playerId,
                connection = connection,
                db = serverContext.db
            )

            val playerContext = serverContext.playerContextTracker.getContext(connection.playerId)
            if (playerContext != null) {
                val batchRecycleJobs = playerContext.services.batchRecycleJob.getBatchRecycleJobs()
                val currentTime = io.ktor.util.date.getTimeMillis()

                for (job in batchRecycleJobs) {
                    val endTime = job.start + (job.end.toLong() * 1000)

                    if (currentTime < endTime) {
                        val secondsRemaining = ((endTime - currentTime) / 1000).toInt()
                        serverContext.taskDispatcher.runTaskFor(
                            connection = connection,
                            taskToRun = server.tasks.impl.BatchRecycleCompleteTask(
                                taskInputBlock = {
                                    this.jobId = job.id
                                    this.duration = secondsRemaining.seconds
                                    this.serverContext = serverContext
                                },
                                stopInputBlock = {
                                    this.jobId = job.id
                                }
                            )
                        )
                    }
                }
            }

            // Second message: game ready message
            val gameReadyMsg = listOf(
                NetworkMessage.GAME_READY,
                Time.now(),
                produceBinaries(),
                CostTable.toJsonString(),
                SurvivorClassTable.toJsonString(),
                LoginStateBuilder.build(serverContext, connection.playerId)
            )

            send(PIOSerializer.serialize(gameReadyMsg), enableLogging = false)
            Logger.debug { "Sent game ready message to playerId=$userId" }
        } else if (joinInfo.roomType == room.RoomType.CHAT) {
            // Pour les ChatRooms, envoyer initialJoin maintenant que le client a reçu joinresult
            // et a enregistré ses handlers
            val chatRoom = roomJoined as? room.chat.ChatRoom
            if (chatRoom != null) {
                chatRoom.sendInitialJoinToPlayer(userId)
                Logger.debug { "Sent initialJoin to playerId=$userId in ChatRoom" }
            } else {
                Logger.error { "Room ${joinInfo.roomId} is not a ChatRoom but roomType is CHAT" }
            }
        } else if (joinInfo.roomType == room.RoomType.ALLIANCE) {
            // Pour les AllianceRooms, envoyer allianceData maintenant que le client a reçu joinresult
            // et a enregistré ses handlers
            val allianceRoom = roomJoined as? room.alliance.AllianceRoom
            if (allianceRoom != null) {
                allianceRoom.sendAllianceDataToPlayer(userId)
                Logger.debug { "Sent allianceData to playerId=$userId in AllianceRoom" }
            } else {
                Logger.error { "Room ${joinInfo.roomId} is not an AllianceRoom but roomType is ALLIANCE" }
            }
        } else {
            // Pour les autres types de rooms (TRADE),
            // les messages initiaux sont gérés par la room elle-même si nécessaire
            Logger.debug { "Joined ${joinInfo.roomType} room, no additional messages needed" }
        }
    }

    /**
     * Pack all xml.gz resources in data/xml/ and manually added compressed
     * resources_secondary.xml.gz in data/
     *
     * Core.swf doesn't request these, the server has to send it manually.
     */
    fun produceBinaries(): ByteArray {
        val xmlResources = listOf(
            "static/game/data/resources_secondary.xml",
            "static/game/data/resources_mission.xml",
            "static/game/data/xml/alliances.xml.gz",
            "static/game/data/xml/arenas.xml.gz",
            "static/game/data/xml/attire.xml.gz",
            "static/game/data/xml/badwords.xml.gz",
            "static/game/data/xml/buildings.xml.gz",
            "static/game/data/xml/config.xml.gz",
            "static/game/data/xml/crafting.xml.gz",
            "static/game/data/xml/effects.xml.gz",
            "static/game/data/xml/humanenemies.xml.gz",
            "static/game/data/xml/injury.xml.gz",
            "static/game/data/xml/itemmods.xml.gz",
            "static/game/data/xml/items.xml.gz",
            "static/game/data/xml/quests.xml.gz",
            "static/game/data/xml/quests_global.xml.gz",
            "static/game/data/xml/raids.xml.gz",
            "static/game/data/xml/skills.xml.gz",
            "static/game/data/xml/streetstructs.xml.gz",
            "static/game/data/xml/survivor.xml.gz",
            "static/game/data/xml/vehiclenames.xml.gz",
            "static/game/data/xml/zombie.xml.gz",
            "static/game/data/xml/scenes/compound.xml.gz",
            "static/game/data/xml/scenes/interior-gunstore-1.xml.gz",
            "static/game/data/xml/scenes/street-small-1.xml.gz",
            "static/game/data/xml/scenes/street-small-2.xml.gz",
            "static/game/data/xml/scenes/street-small-3.xml.gz",
            "static/game/data/xml/scenes/set-motel.xml.gz",
        )

        val output = ByteArrayOutputStream()

        // 1. Write number of files as a single byte
        output.write(xmlResources.size)

        for (path in xmlResources) {
            File(path).inputStream().use {
                val rawBytes = it.readBytes()

                val fileBytes = if (path.endsWith(".gz")) {
                    rawBytes
                } else {
                    val compressed = ByteArrayOutputStream()
                    GZIPOutputStream(compressed).use { gzip ->
                        gzip.write(rawBytes)
                    }
                    compressed.toByteArray()
                }

                val uri = path
                    .removePrefix("static/game/data/")
                    .removeSuffix(".gz")
                val uriBytes = uri.toByteArray(Charsets.UTF_8)

                // 2. Write URI length as 2-byte little endian
                output.writeShortLE(uriBytes.size)

                // 3. Write URI bytes
                output.write(uriBytes)

                // 4. Write file size as 4-byte little endian
                output.writeIntLE(fileBytes.size)

                // 5. Write file data
                output.write(fileBytes)
            }
        }

        return output.toByteArray()
    }
}

fun ByteArrayOutputStream.writeShortLE(value: Int) {
    val buf = ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort(value.toShort())
    write(buf.array())
}

fun ByteArrayOutputStream.writeIntLE(value: Int) {
    val buf = ByteBuffer.allocate(4).order(ByteOrder.LITTLE_ENDIAN).putInt(value)
    write(buf.array())
}
