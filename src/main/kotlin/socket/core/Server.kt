package dev.deadzone.socket.core

import dev.deadzone.SERVER_HOST
import dev.deadzone.SOCKET_SERVER_PORT
import dev.deadzone.context.ServerContext
import dev.deadzone.socket.handler.*
import dev.deadzone.socket.messaging.SocketMessage
import dev.deadzone.socket.messaging.SocketMessageDispatcher
import dev.deadzone.socket.protocol.PIODeserializer
import dev.deadzone.socket.tasks.impl.BuildingTask
import dev.deadzone.socket.tasks.impl.TimeUpdateTask
import dev.deadzone.utils.Logger
import dev.deadzone.utils.UUID
import io.ktor.network.selector.*
import io.ktor.network.sockets.*
import io.ktor.util.date.*
import io.ktor.utils.io.*
import kotlinx.coroutines.*

const val POLICY_FILE_REQUEST = "<policy-file-request/>"
const val POLICY_FILE_RESPONSE =
    "<cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"7777\"/></cross-domain-policy>\u0000"

class Server(
    private val host: String = SERVER_HOST,
    private val port: Int = SOCKET_SERVER_PORT,
    private val context: ServerContext,
    private val coroutineScope: CoroutineScope = CoroutineScope(Dispatchers.IO + SupervisorJob()),
) {
    private val socketDispatcher = SocketMessageDispatcher()

    init {
        with(context) {
            socketDispatcher.register(JoinHandler(this))
            socketDispatcher.register(AuthHandler())
            socketDispatcher.register(QuestProgressHandler(this))
            socketDispatcher.register(InitCompleteHandler(this))
            socketDispatcher.register(SaveHandler(this))
            socketDispatcher.register(ZombieAttackHandler(this))
            socketDispatcher.register(RequestSurvivorCheckHandler())
            context.taskDispatcher.register(TimeUpdateTask(this))
            context.taskDispatcher.register(BuildingTask(this))
        }
    }

    fun start() {
        coroutineScope.launch {
            try {
                val selectorManager = SelectorManager(Dispatchers.IO)
                val serverSocket = aSocket(selectorManager).tcp().bind(host, port)
                Logger.info { "Socket server started at $host:$port" }

                while (true) {
                    val socket = serverSocket.accept()

                    val connection = Connection(
                        connectionId = UUID.new(),
                        socket = socket,
                        output = socket.openWriteChannel(autoFlush = true),
                    )
                    Logger.info { "New client: ${connection.socket.remoteAddress}" }
                    handleClient(connection)
                }
            } catch (e: Exception) {
                Logger.error { "ERROR on server: $e" }
                shutdown()
            }
        }
    }

    private fun handleClient(connection: Connection) {
        coroutineScope.launch {
            val socket = connection.socket
            val input = socket.openReadChannel()

            try {
                val buffer = ByteArray(4096)

                while (true) {
                    val bytesRead = input.readAvailable(buffer, 0, buffer.size)
                    if (bytesRead <= 0) break

                    val data = buffer.copyOfRange(0, bytesRead)
                    Logger.debug { "Received raw: ${data.decodeToString()}" }

                    if (data.startsWithBytes(POLICY_FILE_REQUEST.toByteArray())) {
                        connection.sendRaw(POLICY_FILE_RESPONSE.toByteArray())
                        Logger.info { "Policy file request received and sent" }
                        break
                    }

                    val data2 = if (data.startsWithBytes(byteArrayOf(0x00))) {
                        Logger.info { "Received 0x00 — ignoring" }
                        data.drop(1).toByteArray()
                    } else data

                    val deserialized = PIODeserializer.deserialize(data2)
                    val msg = SocketMessage.fromRaw(deserialized)
                    if (msg.isEmpty()) continue

                    socketDispatcher.findHandlerFor(msg).let { handler ->
                        handler.handle(connection, msg) { response ->
                            // Each handler serialize the message, so sendRaw directly
                            connection.sendRaw(response)
                        }
                    }

                    Logger.info("<------------ SOCKET MESSAGE END ------------>")
                }
            } catch (e: Exception) {
                Logger.error { "Error in socket for ${connection.socket.remoteAddress}: $e" }
                e.printStackTrace()
                context.onlinePlayerRegistry.markOffline(connection.playerId)
                context.playerAccountRepository.updateLastLogin(connection.playerId, getTimeMillis())
                context.playerContextTracker.removePlayer(connection.playerId)
//                context.taskDispatcher.stopAllTasksForPlayer(connection.playerId)
            } finally {
                Logger.info { "Client ${connection.socket.remoteAddress} disconnected" }
                context.onlinePlayerRegistry.markOffline(connection.playerId)
                context.playerAccountRepository.updateLastLogin(connection.playerId, getTimeMillis())
                context.playerContextTracker.removePlayer(connection.playerId)
                context.taskDispatcher.stopAllTasksForPlayer(connection.playerId)
                connection.shutdown()
            }
        }
    }

    fun shutdown() {
        context.playerContextTracker.shutdown()
        context.onlinePlayerRegistry.shutdown()
        context.sessionManager.shutdown()
        context.taskDispatcher.shutdown()
        socketDispatcher.shutdown()
        Logger.info { "Server closed." }
    }
}

fun ByteArray.startsWithBytes(prefix: ByteArray): Boolean {
    if (this.size < prefix.size) return false
    for (i in prefix.indices) {
        if (this[i] != prefix[i]) return false
    }
    return true
}
