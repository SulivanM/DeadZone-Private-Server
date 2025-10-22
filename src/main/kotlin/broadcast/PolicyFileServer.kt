package broadcast

import utils.Logger
import java.io.IOException
import java.net.InetSocketAddress
import java.nio.ByteBuffer
import java.nio.channels.SelectionKey
import java.nio.channels.Selector
import java.nio.channels.ServerSocketChannel
import java.nio.channels.SocketChannel
import kotlin.concurrent.thread

/**
 * Flash Player policy file server
 * Required for Flash to establish socket connections
 * Must run on port 843 (requires admin/root on Linux)
 */
class PolicyFileServer(
    private val host: String = "0.0.0.0",
    private val port: Int = 843,
    private val allowedPorts: List<Int> = listOf(2121, 2122, 2123)
) {
    private var serverChannel: ServerSocketChannel? = null
    private var selector: Selector? = null
    private var running = false
    private var serverThread: Thread? = null

    // Policy file request from Flash
    private val POLICY_REQUEST = "<policy-file-request/>\u0000"

    // Policy file response
    private fun generatePolicyFile(): String {
        val portsString = allowedPorts.joinToString(",")
        return """<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
    <allow-access-from domain="*" to-ports="$portsString" />
</cross-domain-policy>
"""
    }

    /**
     * Starts the policy file server
     */
    fun start() {
        if (running) {
            Logger.warn("Policy file server already running")
            return
        }

        try {
            running = true
            selector = Selector.open()

            serverChannel = ServerSocketChannel.open()
            serverChannel?.configureBlocking(false)
            serverChannel?.bind(InetSocketAddress(host, port))
            serverChannel?.register(selector, SelectionKey.OP_ACCEPT)

            serverThread = thread(name = "PolicyFileServer") {
                runServerLoop()
            }
        } catch (e: IOException) {
            Logger.error("Failed to start policy file server on port $port: ${e.message}")
            Logger.warn("Note: Port 843 requires administrator/root privileges on most systems")
            running = false
        }
    }

    /**
     * Stops the policy file server
     */
    fun stop() {
        if (!running) return

        running = false
        Logger.info("Stopping policy file server...")

        serverChannel?.close()
        serverChannel = null

        selector?.close()
        selector = null

        serverThread?.interrupt()
        serverThread = null

    }

    /**
     * Main server loop
     */
    private fun runServerLoop() {
        while (running) {
            try {
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
                    Logger.error("Error in policy file server loop: ${e.message}")
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
        } catch (e: IOException) {
            Logger.error("Failed to accept policy file request: ${e.message}")
        }
    }

    /**
     * Handles policy file requests
     */
    private fun handleRead(key: SelectionKey) {
        val clientChannel = key.channel() as SocketChannel
        val buffer = ByteBuffer.allocate(256)

        try {
            val bytesRead = clientChannel.read(buffer)

            if (bytesRead == -1) {
                clientChannel.close()
                return
            }

            buffer.flip()
            val request = String(buffer.array(), 0, buffer.limit(), Charsets.UTF_8)

            // Check if it's a policy file request
            if (request.startsWith("<policy-file-request/>")) {
                val policyFile = generatePolicyFile()
                val response = ByteBuffer.wrap(policyFile.toByteArray(Charsets.UTF_8))
                clientChannel.write(response)
            }

            // Close connection after sending response
            clientChannel.close()
        } catch (e: IOException) {
            try {
                clientChannel.close()
            } catch (ignored: IOException) {
            }
        }
    }
}
