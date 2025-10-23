package broadcast

import context.ServerContext
import dev.deadzone.socket.core.Server
import io.ktor.network.selector.*
import io.ktor.network.sockets.*
import io.ktor.utils.io.*
import kotlinx.coroutines.*
import socket.core.startsWithBytes
import utils.Logger

val POLICY_FILE_REQUEST = "<policy-file-request/>".toByteArray()

data class PolicyFileServerConfig(
    val host: String = "0.0.0.0",
    val port: Int = 843,
    val allowedPorts: List<Int> = listOf(2121, 2122, 2123)
)

/**
 * Flash Player policy file server
 * Required for Flash to establish socket connections
 * Must run on port 843 (requires admin/root on Linux)
 */
class PolicyFileServer(private val config: PolicyFileServerConfig) : Server {
    override val name: String = "PolicyFileServer"

    private lateinit var policyServerScope: CoroutineScope

    private val selectorManager = SelectorManager(Dispatchers.IO)

    private var running = false
    override fun isRunning(): Boolean = running

    override suspend fun initialize(scope: CoroutineScope, context: ServerContext) {
        this.policyServerScope = CoroutineScope(scope.coroutineContext + SupervisorJob() + Dispatchers.IO)
    }

    /**
     * Starts the policy file server
     */
    override suspend fun start() {
        if (running) {
            Logger.warn("Policy file server already running")
            return
        }
        running = true

        policyServerScope.launch {
            try {
                val selectorManager = SelectorManager(Dispatchers.IO)
                val serverSocket = aSocket(selectorManager).tcp().bind(config.host, config.port)

                while (isActive) {
                    val socket = serverSocket.accept()
                    handleClient(socket)
                }
            } catch (e: Exception) {
                Logger.error { "ERROR in policy file server on port ${config.port}: ${e.message}" }
                Logger.warn { "Note: Port 843 requires administrator/root privileges on most systems" }
                shutdown()
            }
        }
    }

    fun handleClient(socket: Socket) {
        policyServerScope.launch(Dispatchers.IO + SupervisorJob()) {
            val input = socket.openReadChannel()
            val output = socket.openWriteChannel(autoFlush = true)

            try {
                val buffer = ByteArray(4096)

                while (isActive) {
                    val bytesRead = input.readAvailable(buffer, 0, buffer.size)
                    if (bytesRead <= 0) break

                    // Check if it's policy file request
                    val request = buffer.copyOfRange(0, bytesRead)
                    if (request.startsWithBytes(POLICY_FILE_REQUEST)) {
                        val policyFile = generatePolicyFile().toByteArray(Charsets.UTF_8)
                        output.writeFully(policyFile)
                    }

                    // Break, then close connection after sending response
                    break
                }
            } catch (e: Exception) {
                Logger.error("Error in policy file server during handling a client: ${e.message}")
            } finally {
                socket.close()
            }
        }
    }

    // Policy file response
    private fun generatePolicyFile(): String {
        val portsString = config.allowedPorts.joinToString(",")
        return """<?xml version="1.0"?>
<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
<cross-domain-policy>
    <allow-access-from domain="*" to-ports="$portsString" />
</cross-domain-policy>
"""
    }

    override suspend fun shutdown() {
        policyServerScope.cancel()
        selectorManager.close()
        Logger.info("Policy file server stopped")
    }
}
