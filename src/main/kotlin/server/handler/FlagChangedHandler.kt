package server.handler

import context.ServerContext
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler

/**
 * Handle `fc` (FLAG_CHANGED) message.
 *
 * AS3 Client: connection.send("fc", flagId, booleanValue)
 * Format: ["fc", 4, true]
 *
 * Fire-and-forget message (no response expected).
 * Used to update player flags like tutorial completion, help states, etc.
 *
 * Player Flags (ID 0-10):
 * 0=NicknameVerified, 1=RefreshNeighbors, 2=TutorialComplete, 3=InjurySustained,
 * 4=InjuryHelpComplete, 5=AutoProtectionApplied, 6=TutorialCrateFound,
 * 7=TutorialCrateUnlocked, 8=TutorialSchematicFound, 9=TutorialEffectFound,
 * 10=TutorialPvPPractice
 */
class FlagChangedHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.FLAG_CHANGED
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "FLAG_CHANGED: No playerId in connection" }
            return
        }

        // Extract flag ID and value from positional parameters
        // Message: ["fc", flagId (int), flagValue (boolean)]
        val flagId = message.getInt(0)
        val flagValue = message.getBoolean(1)

        if (flagId == null || flagValue == null) {
            Logger.warn(LogConfigSocketToClient) {
                "FLAG_CHANGED: Invalid message format for playerId=$playerId, raw=${message.getRaw()}"
            }
            return
        }

        Logger.debug(LogConfigSocketToClient) {
            "FLAG_CHANGED: Player $playerId setting flag $flagId = $flagValue"
        }

        // Load player objects
        val playerObjects = serverContext.db.loadPlayerObjects(playerId)
        if (playerObjects == null) {
            Logger.warn(LogConfigSocketToClient) {
                "FLAG_CHANGED: PlayerObjects not found for playerId=$playerId"
            }
            return
        }

        // Update the flag in ByteArray
        val flags = playerObjects.flags.copyOf()
        val byteIndex = flagId / 8
        val bitIndex = flagId % 8
        if (flagValue) {
            flags[byteIndex] = (flags[byteIndex].toInt() or (1 shl bitIndex)).toByte()
        } else {
            flags[byteIndex] = (flags[byteIndex].toInt() and (1 shl bitIndex).inv()).toByte()
        }
        val updatedPlayerObjects = playerObjects.copy(flags = flags)
        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

        Logger.debug(LogConfigSocketToClient) {
            "FLAG_CHANGED: Successfully updated flag $flagId for player $playerId"
        }
    }
}
