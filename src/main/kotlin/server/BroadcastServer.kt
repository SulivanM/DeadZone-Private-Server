package dev.deadzone.socket.core

import server.broadcast.BroadcastMessage
import context.ServerContext
import io.ktor.network.selector.*
import io.ktor.network.sockets.*
import io.ktor.utils.io.*
import kotlinx.coroutines.*
import server.core.Server
import utils.Emoji
import utils.Logger
import java.io.IOException
import java.util.*
import java.util.concurrent.ConcurrentHashMap

data class BroadcastServerConfig(
    val host: String = "0.0.0.0",
    val ports: List<Int> = listOf(2121, 2122, 2123),
)

data class BroadcastClient(
    val clientId: UUID,
    val remoteAddress: String,
    
    val job: Job,
    
    val output: ByteWriteChannel
)

class BroadcastServer(private val config: BroadcastServerConfig) : Server {
    override val name: String = "BroadcastServer"

    private lateinit var broadcastServerScope: CoroutineScope

    private val selectorManager = SelectorManager(Dispatchers.IO)

    private val serverSockets = mutableListOf<ServerSocket>()

    private val serverJobs = mutableListOf<Job>()

    private val clients = ConcurrentHashMap<UUID, BroadcastClient>()

    private var running = false
    override fun isRunning(): Boolean = running

    fun getClientCount(): Int = clients.size

    override suspend fun initialize(scope: CoroutineScope, context: ServerContext) {
        broadcastServerScope = CoroutineScope(scope.coroutineContext + SupervisorJob() + Dispatchers.IO)
    }

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
        val clientId = UUID.randomUUID()
        Logger.info("New broadcast connection from $address")

        val job = broadcastServerScope.launch(Dispatchers.IO + SupervisorJob()) {
            val input = socket.openReadChannel()

            try {
                val buffer = ByteArray(1024)
                while (isActive) {
                    val bytes = input.readAvailable(buffer)
                    if (bytes <= 0) break 
                    
                    
                }
            } catch (e: Exception) {
                Logger.warn("Broadcast socket error for $address: ${e.message}")
            } finally {
                removeClient(clientId)
                socket.close()
                Logger.info("Closed broadcast connection $address")
            }
        }
        clients[clientId] = BroadcastClient(
            clientId = clientId,
            remoteAddress = address.toString(),
            job = job,
            output = socket.openWriteChannel(autoFlush = true)
        )
    }

    private fun removeClient(clientId: UUID) {
        if (clients.remove(clientId) != null) {
            Logger.info("${Emoji.Phone} Client disconnected from broadcast (${clients.size} total)")
        } else {
            Logger.warn("${Emoji.Phone} Requested to remove client, but it wasn't in the collection (${clients.size} total)")
        }
    }

    suspend fun broadcast(message: BroadcastMessage) {
        val wireFormat = message.toWireFormat()
        broadcast(wireFormat)
    }

    suspend fun broadcast(message: String) {
        if (clients.isEmpty()) {
            return
        }

        val bytesData = message.toByteArray(Charsets.UTF_8)
        val disconnectedClients = mutableListOf<UUID>()

        clients.values.forEach { client ->
            try {
                client.output.writeFully(bytesData)
            } catch (e: IOException) {
                Logger.warn("Failed to send broadcast to client: ${e.message}")
                disconnectedClients.add(client.clientId)
            }
        }

        disconnectedClients.forEach { client ->
            removeClient(client)
        }
    }

    override suspend fun shutdown() {
        running = false
        clients.clear()
        clients.forEach { (_, u) ->
            u.output.flushAndClose()
            u.job.cancelAndJoin()
        }
        serverSockets.forEach { it.close() }
        serverJobs.forEach { it.cancelAndJoin() }
        broadcastServerScope.cancel()
        selectorManager.close()
        Logger.info("${Emoji.Satellite} Broadcast server stopped.")
    }
}
