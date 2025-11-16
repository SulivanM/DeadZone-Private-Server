package server.handler

import context.ServerContext
import server.messaging.HandlerContext
import common.LogConfigSocketToClient
import common.Logger
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer

/**
 * Handle `lsv` and `lsv_ok` (Long Session Validation) messages.
 *
 * AS3 Client sends: connection.send("lsv") or connection.send("lsv_ok")
 * Format: ["lsv"] or ["lsv_ok"]
 *
 * LSV is a challenge-based validation mechanism to prevent AFK abuse during long sessions.
 * The client displays a 6-character CAPTCHA challenge when "lsv" is sent.
 * User has 15 minutes to complete the challenge, or they are kicked.
 * Challenge generation happens client-side; server just acknowledges the request.
 *
 * From: LongSessionValidationDialogue.as:110, 123
 */
class LongSessionValidationHandler(private val serverContext: ServerContext) : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == "lsv" || message.type == "lsv_ok" ||
                message.contains("lsv") || message.contains("lsv_ok")
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val playerId = connection.playerId
        if (playerId == null) {
            Logger.warn(LogConfigSocketToClient) { "LONG_SESSION_VALIDATION: No playerId in connection" }
            return
        }

        val messageType = if (message.type == "lsv_ok" || message.contains("lsv_ok")) {
            "lsv_ok"
        } else {
            "lsv"
        }

        Logger.debug(LogConfigSocketToClient) {
            "LONG_SESSION_VALIDATION: Player $playerId sent $messageType"
        }

        when (messageType) {
            "lsv" -> {
                val response = listOf("lsv_response")
                send(PIOSerializer.serialize(response))

                Logger.debug(LogConfigSocketToClient) {
                    "LONG_SESSION_VALIDATION: Sent lsv_response to player $playerId (challenge generated client-side)"
                }
            }
            "lsv_ok" -> {
                Logger.debug(LogConfigSocketToClient) {
                    "LONG_SESSION_VALIDATION: Player $playerId confirmed activity (passed challenge)"
                }
            }
        }
    }
}
