package server.core

import io.ktor.utils.io.ByteReadChannel
import io.ktor.utils.io.ByteWriteChannel
import io.ktor.utils.io.writeFully
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.cancel
import server.protocol.PIOSerializer
import common.Logger
import common.UUID

/**
 * Representation of a player connection.
 * @property playerId reference to which player does this socket belongs to. Only known after client send join message.
 */
class Connection(
    var playerId: String = "[Undetermined]",
    val connectionId: String = UUID.new(),
    val remoteAddress: String,
    val input: ByteReadChannel,
    val output: ByteWriteChannel,
    val connectionScope: CoroutineScope,
) {
    private var lastActivity = System.currentTimeMillis()

    /**
     * Join data stocké lors du createJoinRoom
     * Utilisé pour initialiser le joueur dans les rooms
     */
    var joinData: Map<String, Any> = emptyMap()

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
            Logger.error { "Failed to send raw message to $remoteAddress: ${e.message}" }
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
            Logger.error { "Failed to send message of type '$type' to $remoteAddress: ${e.message}" }
            throw e
        }
    }

    /**
     * Send a Message object (synchronous wrapper)
     * Used by Room system for broadcasting
     */
    fun send(message: api.message.Message) {
        kotlinx.coroutines.runBlocking {
            val args = message.toList()
            if (args.isNotEmpty()) {
                sendMessage(args[0].toString(), *args.drop(1).toTypedArray())
            }
        }
    }

    fun shutdown() {
        try {
            connectionScope.cancel()
        } catch (e: Exception) {
            Logger.warn { "Exception during connection shutdown: ${e.message}" }
        }
    }

    override fun toString(): String {
        return "Connnection(playerId=$playerId, connectionId=$connectionId, address=$remoteAddress)"
    }
}