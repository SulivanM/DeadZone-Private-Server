package server.handler

import context.ServerContext
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler

/**
 * Handle `scvend` (SCAV_ENDED) message.
 *
 * AS3 Client: connection.send("scvend", scavIndex, endTime, timeToSearch, timeSearching)
 * Format: ["scvend", 5, 12345678, 5000, 5100]
 *
 * Fire-and-forget message for tracking scavenging completion.
 * Validates duration against SCAV_STARTED to detect cheating.
 *
 * Parameters:
 * - scavIndex: Matches SCAV_STARTED index
 * - endTime: Client timestamp when scavenge completed
 * - timeToSearch: Expected duration in milliseconds
 * - timeSearching: Actual elapsed time in milliseconds
 */
class ScavEndedHandler(private val serverContext: ServerContext) : SocketMessageHandler {

    companion object {
        // Tolerance for client/server time drift (5 seconds)
        private const val TIME_TOLERANCE_MS = 5000L
        // Maximum reasonable scavenge time (5 minutes)
        private const val MAX_SCAVENGE_TIME_MS = 300_000L
    }

    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.SCAV_ENDED
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "SCAV_ENDED: No playerId in connection" }
            return
        }

        // Extract scavenge end data: ["scvend", scavIndex, endTime, timeToSearch, timeSearching]
        val scavIndex = message.getInt(0)
        val clientEndTime = message.getLong(1)
        val timeToSearch = message.getLong(2)
        val timeSearching = message.getLong(3)

        if (scavIndex == null || clientEndTime == null || timeToSearch == null || timeSearching == null) {
            Logger.warn(LogConfigSocketToClient) {
                "SCAV_ENDED: Invalid message format for playerId=$playerId, raw=${message.getRaw()}"
            }
            return
        }

        // Validate against SCAV_STARTED data (via companion object access)
        val startData = ScavStartedHandler.getScavengeStartData(playerId, scavIndex)
        if (startData == null) {
            Logger.warn(LogConfigSocketToClient) {
                "SCAV_ENDED: No matching SCAV_STARTED for player $playerId scavIndex $scavIndex (possible restart or timeout)"
            }
            // Don't return error - just log it (player may have restarted client)
        } else {
            // Validate timing
            val serverElapsed = System.currentTimeMillis() - startData.serverStartTime
            val clientElapsed = timeSearching

            // Check if client time is reasonable compared to server time
            val timeDiff = kotlin.math.abs(serverElapsed - clientElapsed)
            if (timeDiff > TIME_TOLERANCE_MS) {
                Logger.warn(LogConfigSocketToClient) {
                    "SCAV_ENDED: Suspicious timing for player $playerId scavIndex $scavIndex: " +
                            "server elapsed=$serverElapsed ms, client elapsed=$clientElapsed ms, diff=$timeDiff ms"
                }
            }

            // Check if scavenge time exceeds maximum
            if (timeSearching > MAX_SCAVENGE_TIME_MS) {
                Logger.warn(LogConfigSocketToClient) {
                    "SCAV_ENDED: Excessive scavenge time for player $playerId: $timeSearching ms"
                }
            }

            // Clean up start data
            ScavStartedHandler.clearScavengeData(playerId, scavIndex)
        }

        Logger.debug(LogConfigSocketToClient) {
            "SCAV_ENDED: Player $playerId completed scavenge #$scavIndex: " +
                    "expected=${timeToSearch}ms, actual=${timeSearching}ms"
        }
    }
}
