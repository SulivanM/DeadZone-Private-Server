package server.handler

import context.ServerContext
import core.LoginStateBuilder
import dev.deadzone.socket.messaging.HandlerContext
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer
import utils.Logger
import utils.Time
import java.io.ByteArrayOutputStream
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.zip.GZIPOutputStream
import kotlin.time.Duration.Companion.seconds

class JoinHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.getString(NetworkMessage.JOIN) != null
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val joinKey = message.getString(NetworkMessage.JOIN)
        Logger.debug { "Handling join with key: $joinKey" }

        val userId = if (joinKey != null) {
            serverContext.joinKeyManager.resolve(joinKey)
                ?: throw IllegalArgumentException("Invalid or expired join key: $joinKey")
        } else {
            throw IllegalArgumentException("No join key provided")
        }
        connection.playerId = userId

        serverContext.allianceCreationTracker.clearTracking(userId)

        val success = true
        val joinResultMsg = listOf(NetworkMessage.JOIN_RESULT, success)
        send(PIOSerializer.serialize(joinResultMsg), enableLogging = false)
        Logger.debug { "Sent playerio.joinresult:$success to playerId=$userId" }

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

        val gameReadyMsg = listOf(
            NetworkMessage.GAME_READY,
            Time.now(),
            produceBinaries(),
            loadRawFile("static/data/cost_table.json"),
            loadRawFile("static/data/srv_table.json"),
            LoginStateBuilder.build(serverContext, connection.playerId)
        )

        send(PIOSerializer.serialize(gameReadyMsg), enableLogging = false)
        Logger.debug { "Sent game ready message to playerId=$userId" }
    }

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

                output.writeShortLE(uriBytes.size)

                output.write(uriBytes)

                output.writeIntLE(fileBytes.size)

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
