package dev.deadzone.socket.handler

import dev.deadzone.context.GlobalContext
import dev.deadzone.context.ServerContext
import dev.deadzone.core.LoginStateBuilder
import dev.deadzone.core.data.PlayerLoginState
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.messaging.NetworkMessage
import dev.deadzone.socket.messaging.SocketMessage
import dev.deadzone.socket.messaging.SocketMessageHandler
import dev.deadzone.socket.protocol.PIOSerializer
import dev.deadzone.utils.Logger
import dev.deadzone.utils.Time
import io.ktor.util.date.*
import java.io.ByteArrayOutputStream
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.zip.GZIPOutputStream

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

    override suspend fun handle(connection: Connection, message: SocketMessage, send: suspend (ByteArray) -> Unit) {
        val joinKey = message.getString(NetworkMessage.JOIN)
        Logger.debug { "Handling join with key: $joinKey" }

        val userId = message.getString("serviceUserId")
            ?: throw IllegalArgumentException("No userId for connection: $connection")
        connection.playerId = userId

        // First message: join result
        val joinResultMsg = listOf(NetworkMessage.JOIN_RESULT, true)
        send(PIOSerializer.serialize(joinResultMsg))

        // Create PlayerContext which initializes per-player services
        serverContext.playerContextTracker.createContext(
            playerId = connection.playerId,
            connection = connection,
            db = serverContext.db,
            useMongo = serverContext.config.useMongo
        )

        // Second message: game ready message
        val gameReadyMsg = listOf(
            NetworkMessage.GAME_READY,
            Time.now(),
            produceBinaries(),
            loadRawFile("static/data/cost_table.json"),
            loadRawFile("static/data/srv_table.json"),
            LoginStateBuilder.build(serverContext, connection.playerId)
        )
        send(PIOSerializer.serialize(gameReadyMsg))
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

    fun loadRawFile(path: String): String {
        return File(path).readText()
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
