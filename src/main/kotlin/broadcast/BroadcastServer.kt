package broadcast

import utils.Logger
import java.io.IOException
import java.net.InetSocketAddress
import java.nio.ByteBuffer
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.ServerSocketChannel
import java.nio.channels.SocketChannel
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.CopyOnWriteArrayList
import kotlin.concurrent.thread

/**
 * TCP Socket server for handling broadcast connections from Flash clients
 * Supports multiple ports for different game services
 */
class BroadcastServer(
    private val host: String = "0.0.0.0",
    private val ports: List<Int> = listOf(2121, 2122, 2123)
) {
    private val serverChannels = mutableListOf<ServerSocketChannel>()
    private val clients = CopyOnWriteArrayList<SocketChannel>()
    private val clientBuffers = ConcurrentHashMap<SocketChannel, ByteBuffer>()
    private var selector: Selector? = null
    private var running = false
    private var serverThread: Thread? = null

    /**
     * Starts the broadcast server on all configured ports
     */
    fun start() {
        if (running) {
            Logger.warn("Broadcast server already running")
            return
        }

        running = true
        selector = Selector.open()

        // Start server on each port
        val startedPorts = mutableListOf<Int>()
        ports.forEach { port ->
            try {
                val serverChannel = ServerSocketChannel.open()
                serverChannel.configureBlocking(false)
                serverChannel.bind(InetSocketAddress(host, port))
                serverChannel.register(selector, SelectionKey.OP_ACCEPT)
                serverChannels.add(serverChannel)
                startedPorts.add(port)
            } catch (e: IOException) {
                Logger.error("Failed to start broadcast server on port $port: ${e.message}")
            }
        }

        if (startedPorts.isNotEmpty()) {
            Logger.info("📡 Broadcast listening on ${startedPorts.joinToString(", ")}")
        }

        // Start server thread
        serverThread = thread(name = "BroadcastServer") {
            runServerLoop()
        }
    }

    /**
     * Stops the broadcast server and closes all connections
     */
    fun stop() {
        if (!running) return

        running = false

        // Close all client connections
        clients.forEach { client ->
            try {
                client.close()
            } catch (e: IOException) {
                // Ignore
            }
        }
        clients.clear()
        clientBuffers.clear()

        // Close all server channels
        serverChannels.forEach { channel ->
            try {
                channel.close()
            } catch (e: IOException) {
                // Ignore
            }
        }
        serverChannels.clear()

        // Close selector
        selector?.close()
        selector = null

        serverThread?.interrupt()
        serverThread = null
    }

    /**
     * Broadcasts a message to all connected clients
     */
    fun broadcast(message: BroadcastMessage) {
        val wireFormat = message.toWireFormat()
        broadcast(wireFormat)
    }

    /**
     * Broadcasts a raw string message to all connected clients
     */
    fun broadcast(message: String) {
        if (clients.isEmpty()) {
            return
        }

        val data = message.toByteArray(Charsets.UTF_8)
        val buffer = ByteBuffer.wrap(data)

        val disconnectedClients = mutableListOf<SocketChannel>()

        clients.forEach { client ->
            try {
                buffer.rewind()
                client.write(buffer)
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

    /**
     * Returns the number of connected clients
     */
    fun getClientCount(): Int = clients.size

    /**
     * Main server loop
     */
    private fun runServerLoop() {

        while (running) {
            try {
                // Wait for events with timeout
                val readyCount = selector?.select(1000) ?: 0
                if (readyCount == 0) continue

                val selectedKeys = selector?.selectedKeys() ?: continue
                val iterator = selectedKeys.iterator()

                while (iterator.hasNext()) {
                    val key = iterator.next()
                    iterator.remove()

                    when {
                        !key.isValid -> continue
                        key.isAcceptable -> handleAccept(key)
                        key.isReadable -> handleRead(key)
                    }
                }
            } catch (e: Exception) {
                if (running) {
                    Logger.error("Error in broadcast server loop: ${e.message}")
                }
            }
        }
    }

    /**
     * Handles new client connections
     */
    private fun handleAccept(key: SelectionKey) {
        val serverChannel = key.channel() as ServerSocketChannel
        try {
            val clientChannel = serverChannel.accept()
            clientChannel.configureBlocking(false)
            clientChannel.register(selector, SelectionKey.OP_READ)

            clients.add(clientChannel)
            clientBuffers[clientChannel] = ByteBuffer.allocate(1024)

            if (clients.size <= 2) {
                Logger.info("📱 Client connected to broadcast (${clients.size} total)")
            }
        } catch (e: IOException) {
            Logger.error("Failed to accept client: ${e.message}")
        }
    }

    /**
     * Handles data from clients (mainly heartbeats)
     */
    private fun handleRead(key: SelectionKey) {
        val clientChannel = key.channel() as SocketChannel
        val buffer = clientBuffers[clientChannel] ?: return

        try {
            buffer.clear()
            val bytesRead = clientChannel.read(buffer)

            when {
                bytesRead == -1 -> {
                    // Client disconnected
                    removeClient(clientChannel)
                }
                bytesRead > 0 -> {
                    // Client sent data (likely heartbeat)
                    // We don't need to process it, just acknowledge the connection is alive
                }
            }
        } catch (e: IOException) {
            removeClient(clientChannel)
        }
    }

    /**
     * Removes a client from the server
     */
    private fun removeClient(clientChannel: SocketChannel) {
        try {
            clientChannel.close()
            clients.remove(clientChannel)
            clientBuffers.remove(clientChannel)
            if (clients.size <= 2) {
                Logger.info("📱 Client disconnected from broadcast (${clients.size} total)")
            }
        } catch (e: IOException) {
            // Ignore
        }
    }
}
