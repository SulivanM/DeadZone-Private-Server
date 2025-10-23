package dev.deadzone.socket.core

import broadcast.BroadcastMessage
import context.ServerContext
import io.ktor.network.selector.*
import io.ktor.network.sockets.*
import io.ktor.utils.io.*
import kotlinx.coroutines.*
import utils.Emoji
import utils.Logger
import java.io.IOException
import java.util.concurrent.ConcurrentLinkedQueue

data class BroadcastServerConfig(
    val host: String = "0.0.0.0",
    val ports: List<Int> = listOf(2121, 2122, 2123),
)

class BroadcastServer(private val config: BroadcastServerConfig) : Server {
    override val name: String = "BroadcastServer"

    private lateinit var broadcastServerScope: CoroutineScope

    private val selectorManager = SelectorManager(Dispatchers.IO)
    private val serverSockets = mutableListOf<ServerSocket>()
    private val serverJobs = mutableListOf<Job>()

    private var running = false
    override fun isRunning(): Boolean = running

    private val clientChannels = ConcurrentLinkedQueue<ByteWriteChannel>()

    /**
     * Returns the number of connected clients
     */
    fun getClientCount(): Int = clientChannels.size

    override suspend fun initialize(scope: CoroutineScope, context: ServerContext) {
        broadcastServerScope = CoroutineScope(scope.coroutineContext + SupervisorJob() + Dispatchers.IO)
    }

    /**
     * Starts the broadcast server on all configured ports
     */
    override suspend fun start() {
        if (running) {
            Logger.warn("Broadcast server is already running")
            return
        }
        running = true

        config.ports.forEach { port ->
            val job = broadcastServerScope.launch(Dispatchers.IO + SupervisorJob()) {
                try {
                    val serverSocket = aSocket(selectorManager).tcp().bind(config.host, port)
                    serverSockets.add(serverSocket)

                    Logger.info("${Emoji.Satellite} Broadcast listening on ${config.host}:$port")

                    while (isActive) {
                        val socket = serverSocket.accept()
                        handleClient(socket)
                    }
                } catch (e: Exception) {
                    Logger.error("Failed to start broadcast server on port $port: ${e.message}")
                }
            }
            serverJobs.add(job)
        }
    }

    private fun handleClient(socket: Socket) {
        val address = socket.remoteAddress
        Logger.info("New broadcast connection from $address")

        broadcastServerScope.launch(Dispatchers.IO + SupervisorJob()) {
            val input = socket.openReadChannel()
            val output = socket.openWriteChannel(autoFlush = true)
            clientChannels.add(output)

            try {
                val buffer = ByteArray(1024)
                while (isActive) {
                    val bytes = input.readAvailable(buffer)
                    if (bytes <= 0) break // client disconnected
                    // client does not need to send data to broadcast server
                    // just ignore it as it is probably just heartbeat
                }
            } catch (e: Exception) {
                Logger.warn("Broadcast socket error for $address: ${e.message}")
            } finally {
                removeClient(output)
                socket.close()
                Logger.info("Closed broadcast connection $address")
            }
        }
    }

    private fun removeClient(channel: ByteWriteChannel) {
        if (clientChannels.remove(channel)) {
            Logger.info("${Emoji.Phone} Client disconnected from broadcast (${clientChannels.size} total)")
        } else {
            Logger.warn("${Emoji.Phone} Requested to remove client, but it wasn't in the collection (${clientChannels.size} total)")
        }
    }

    /**
     * Broadcasts a message to all connected clients
     */
    suspend fun broadcast(message: BroadcastMessage) {
        val wireFormat = message.toWireFormat()
        broadcast(wireFormat)
    }

    /**
     * Broadcasts a raw string message to all connected clients
     */
    suspend fun broadcast(message: String) {
        if (clientChannels.isEmpty()) {
            return
        }

        val bytesData = message.toByteArray(Charsets.UTF_8)
        val disconnectedClients = mutableListOf<ByteWriteChannel>()

        clientChannels.forEach { client ->
            try {
                client.writeFully(bytesData)
            } catch (e: IOException) {
                Logger.warn("Failed to send broadcast to client: ${e.message}")
                disconnectedClients.add(client)
            }
        }

        // Remove disconnected clients
        disconnectedClients.forEach { client ->
            removeClient(client)
        }
    }

    override suspend fun shutdown() {
        running = false
        clientChannels.clear()
        serverSockets.forEach { it.close() }
        serverJobs.forEach { it.cancelAndJoin() }
        selectorManager.close()
        Logger.info("${Emoji.Satellite} Broadcast server stopped.")
    }
}
