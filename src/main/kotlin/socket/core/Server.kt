package socket.core

import dev.deadzone.SERVER_HOST
import dev.deadzone.SOCKET_SERVER_PORT
import context.ServerContext
import dev.deadzone.socket.messaging.HandlerContext
import socket.messaging.SocketMessage
import socket.messaging.SocketMessageDispatcher
import socket.protocol.PIODeserializer
import socket.tasks.impl.BuildingTask
import socket.tasks.impl.TimeUpdateTask
import utils.Logger
import utils.UUID
import io.ktor.network.selector.*
import io.ktor.network.sockets.*
import io.ktor.util.date.*
import io.ktor.utils.io.*
import kotlinx.coroutines.*
import socket.handler.AuthHandler
import socket.handler.InitCompleteHandler
import socket.handler.JoinHandler
import socket.handler.QuestProgressHandler
import socket.handler.RequestSurvivorCheckHandler
import socket.handler.SaveHandler
import socket.handler.ZombieAttackHandler
import java.net.SocketException
import kotlin.system.measureTimeMillis

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
            socketDispatcher.register(QuestProgressHandler())
            socketDispatcher.register(InitCompleteHandler(this))
            socketDispatcher.register(SaveHandler(this))
            socketDispatcher.register(ZombieAttackHandler())
            socketDispatcher.register(RequestSurvivorCheckHandler())
            context.taskDispatcher.register(TimeUpdateTask())
            context.taskDispatcher.register(BuildingTask())
        }
    }

    fun start() {
        coroutineScope.launch {
            try {
                val selectorManager = SelectorManager(Dispatchers.IO)
                val serverSocket = aSocket(selectorManager).tcp().bind(host, port)

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

                    var msgType = "[Undetermined]"
                    val elapsed = measureTimeMillis {
                        val data = buffer.copyOfRange(0, bytesRead)

                        fun ByteArray.decode(max: Int = 512, placeholder: Char = '�'): String {
                            val decoded = String(this, Charsets.UTF_8)
                            val sanitized = decoded.map { ch ->
                                if (ch.isISOControl() && ch != '\n' && ch != '\r' && ch != '\t') placeholder
                                else if (!ch.isDefined() || !ch.isLetterOrDigit() && ch !in setOf(' ', '.', ',', ':', ';', '-', '_', '{', '}', '[', ']', '(', ')', '"', '\'', '/', '\\', '?', '=', '+', '*', '%', '&', '|', '<', '>', '!', '@', '#', '$', '^', '~')) placeholder
                                else ch
                            }.joinToString("")
                            return sanitized.take(max) + if (sanitized.length > max) "..." else ""
                        }

                        Logger.debug {
                            "=====> [SOCKET START]: ${data.decode()} for playerId=${connection.playerId}, bytes=$bytesRead"
                        }

                        if (data.startsWithBytes(POLICY_FILE_REQUEST.toByteArray())) {
                            connection.sendRaw(POLICY_FILE_RESPONSE.toByteArray())
                            break
                        }

                        val data2 = if (data.startsWithBytes(byteArrayOf(0x00))) {
                            data.drop(1).toByteArray()
                        } else data

                        val deserialized = PIODeserializer.deserialize(data2)
                        val msg = SocketMessage.fromRaw(deserialized)
                        if (msg.isEmpty()) continue

                        msgType = msg.msgTypeToString()

                        socketDispatcher.findHandlerFor(msg).handle(HandlerContext(connection, msg))
                    }

                    Logger.debug {
                        buildString {
                            appendLine("<===== [SOCKET END] of type $msgType handled for playerId=${connection.playerId} in ${elapsed}ms")
                            append("————————————————————————————————————————————————————————————————————————————————————————————————————————")
                        }
                    }
                }
            } catch (_: ClosedByteChannelException) {
                // Handle connection reset gracefully - this is expected when clients disconnect abruptly
                Logger.info { "Client ${connection.socket.remoteAddress} disconnected abruptly (connection reset)" }
            } catch (e: SocketException) {
                // Handle other socket-related exceptions gracefully
                when {
                    e.message?.contains("Connection reset") == true -> {
                        Logger.info { "Client ${connection.socket.remoteAddress} connection was reset by peer" }
                    }

                    e.message?.contains("Broken pipe") == true -> {
                        Logger.info { "Client ${connection.socket.remoteAddress} connection broken (broken pipe)" }
                    }

                    else -> {
                        Logger.warn { "Socket exception for ${connection.socket.remoteAddress}: ${e.message}" }
                    }
                }
            } catch (e: Exception) {
                Logger.error { "Unexpected error in socket for ${connection.socket.remoteAddress}: $e" }
                e.printStackTrace()
            } finally {
                // Cleanup logic - this will run regardless of how the connection ended
                Logger.info { "Cleaning up connection for ${connection.socket.remoteAddress}" }

                // Only perform cleanup if playerId is set (client was authenticated)
                if (connection.playerId != "[Undetermined]") {
                    context.onlinePlayerRegistry.markOffline(connection.playerId)
                    context.playerAccountRepository.updateLastLogin(connection.playerId, getTimeMillis())
                    context.playerContextTracker.removePlayer(connection.playerId)
                    context.taskDispatcher.stopAllTasksForPlayer(connection.playerId)
                }

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
    }
}

fun ByteArray.startsWithBytes(prefix: ByteArray): Boolean {
    if (this.size < prefix.size) return false
    for (i in prefix.indices) {
        if (this[i] != prefix[i]) return false
    }
    return true
}
