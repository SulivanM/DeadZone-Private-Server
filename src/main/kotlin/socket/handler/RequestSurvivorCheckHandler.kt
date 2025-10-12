package socket.handler

import dev.deadzone.socket.messaging.HandlerContext
import socket.messaging.NetworkMessage
import socket.messaging.SocketMessage
import socket.messaging.SocketMessageHandler
import socket.protocol.PIOSerializer
import utils.Logger
import utils.Time

/**
 * Handle `rsc` message by:
 *
 * 1. Sending a reponse in JSON with success set to true
 *
 */
class RequestSurvivorCheckHandler() : SocketMessageHandler {
    override fun match(message: SocketMessage): Boolean {
        return message.type == NetworkMessage.REQUEST_SURVIVOR_CHECK || message.contains(NetworkMessage.REQUEST_SURVIVOR_CHECK)
    }

    override suspend fun handle(ctx: HandlerContext) = with(ctx) {
        val id = message.getMap(NetworkMessage.REQUEST_SURVIVOR_CHECK)?.get("id") as? String
        Logger.debug { "Received RSC from playerId=${connection.playerId}" }

        val responseMsg =
            listOf(
                NetworkMessage.SEND_RESPONSE,  // Message Type
                id ?: "m",   // id
                Time.now(),   // server time
                survivorCheckJson.trimIndent() // response
            )
        
        val newSurvivorMsg =
            listOf(
                NetworkMessage.SURVIVOR_NEW,  // Message Type
                survivorNewJson.trimIndent()
            )

        send(PIOSerializer.serialize(responseMsg))
        send(PIOSerializer.serialize(newSurvivorMsg))
    }
}

const val survivorCheckJson = """{"success": true}"""

const val survivorNewJson = """
{
  "id": "",
  "title": "",
  "firstName": "Jesse",
  "lastName": "Pinkman",
  "gender": "male",
  "classId": "unassigned",
  "voice": "white-m"
}
"""
/*
{
  "id": null,
  "title": null,
  "firstName": null,
  "lastName": null,
  "gender": null,
  "portrait": null,
  "classId": null,
  "morale": null,
  "injuries": null,
  "missionId": null,
  "assignmentId": null,
  "reassignTimer": null,
  "appearance": null,
  "scale": null,
  "voice": null
}
*/