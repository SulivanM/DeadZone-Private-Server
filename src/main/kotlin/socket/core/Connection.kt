package socket.core

import socket.protocol.PIOSerializer
import utils.Logger
import utils.UUID
import io.ktor.network.sockets.Socket
import io.ktor.utils.io.ByteWriteChannel
import io.ktor.utils.io.writeFully
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel

/**
 * Representation of a player connection.
 * @property playerId reference to which player does this socket belongs to. Only known after client send join message.
 */
class Connection(
    var playerId: String = "[Undetermined]",
    val connectionId: String = UUID.new(),
    val socket: Socket,
    val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Default),
    private val output: ByteWriteChannel,
) {
    private var lastActivity = System.currentTimeMillis()

    /**
     * Update the last activity timestamp
     */
    fun updateActivity() {
        lastActivity = System.currentTimeMillis()
    }

    /**
     * Send raw unserialized message (non-PIO) to client
     */
    suspend fun sendRaw(b: ByteArray, enableLogging: Boolean = true, logFull: Boolean = true) {
        try {
            if (enableLogging) {
                Logger.debug(logFull = logFull) { "Sending raw: ${b.decodeToString()}" }
            }
            output.writeFully(b)
            updateActivity()
        } catch (e: Exception) {
            Logger.error { "Failed to send raw message to ${socket.remoteAddress}: ${e.message}" }
            throw e
        }
    }

    /**
     * Send a serialized PIO message
     */
    suspend fun sendMessage(type: String, vararg args: Any, enableLogging: Boolean = true, logFull: Boolean = true) {
        try {
            val msg = buildList {
                add(type)
                addAll(args)
            }
            val bytes = PIOSerializer.serialize(msg)

            if (enableLogging) {
                Logger.debug(logFull = logFull) { "Sending message of type '$type' | raw message: ${bytes.decodeToString()}" }
            }

            output.writeFully(bytes)
            updateActivity()
        } catch (e: Exception) {
            Logger.error { "Failed to send message of type '$type' to ${socket.remoteAddress}: ${e.message}" }
            throw e
        }
    }

    fun shutdown() {
        try {
            scope.cancel()
            socket.close()
        } catch (e: Exception) {
            Logger.warn { "Exception during connection shutdown: ${e.message}" }
        }
    }

    override fun toString(): String {
        return "[ADDR]: ${this.socket.remoteAddress} | connectionId=$connectionId"
    }
}
