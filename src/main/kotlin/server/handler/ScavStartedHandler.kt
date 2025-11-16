package server.handler

import context.ServerContext
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import java.util.concurrent.ConcurrentHashMap

/**
 * Handle `scvstrt` (SCAV_STARTED) message.
 *
 * AS3 Client: connection.send("scvstrt", scavIndex, startTime)
 * Format: ["scvstrt", 5, 12345678]
 *
 * Fire-and-forget message for tracking scavenging start.
 * Used for anti-cheat validation when scavenging completes.
 *
 * scavIndex: Unique incrementing index per player session
 * startTime: Client timestamp from getTimer() in milliseconds
 */
class ScavStartedHandler(private val serverContext: ServerContext) : SocketMessageHandler {

    companion object {
        // Track scavenge sessions: playerId -> Map<scavIndex, startData>
        private val scavengeSessions = ConcurrentHashMap<String, MutableMap<Int, ScavengeStartData>>()

        /**
         * Get scavenge start data for validation (called by ScavEndedHandler).
         */
        fun getScavengeStartData(playerId: String, scavIndex: Int): ScavengeStartData? {
            return scavengeSessions[playerId]?.get(scavIndex)
        }

        /**
         * Clear scavenge start data after validation.
         */
        fun clearScavengeData(playerId: String, scavIndex: Int) {
            scavengeSessions[playerId]?.remove(scavIndex)
        }
    }

    data class ScavengeStartData(
        val scavIndex: Int,
        val clientStartTime: Long,
        val serverStartTime: Long
    )

    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.SCAV_STARTED
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "SCAV_STARTED: No playerId in connection" }
            return
        }

        // Extract scavenge data: ["scvstrt", scavIndex, startTime]
        val scavIndex = message.getInt(0)
        val clientStartTime = message.getLong(1)

        if (scavIndex == null || clientStartTime == null) {
            Logger.warn(LogConfigSocketToClient) {
                "SCAV_STARTED: Invalid message format for playerId=$playerId, raw=${message.getRaw()}"
            }
            return
        }

        val serverStartTime = System.currentTimeMillis()

        // Store scavenge start data for later validation
        scavengeSessions.computeIfAbsent(playerId) { mutableMapOf() }[scavIndex] = ScavengeStartData(
            scavIndex = scavIndex,
            clientStartTime = clientStartTime,
            serverStartTime = serverStartTime
        )

        Logger.debug(LogConfigSocketToClient) {
            "SCAV_STARTED: Player $playerId started scavenge #$scavIndex at client time $clientStartTime"
        }
    }
}
