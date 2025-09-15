package dev.deadzone.socket.handler

import dev.deadzone.context.ServerContext
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.messaging.NetworkMessage
import dev.deadzone.socket.messaging.SocketMessage
import dev.deadzone.socket.messaging.SocketMessageHandler
import dev.deadzone.socket.protocol.PIOSerializer
import dev.deadzone.utils.Logger
import dev.deadzone.utils.Time

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

    override suspend fun handle(
        connection: Connection,
        message: SocketMessage,
        send: suspend (ByteArray) -> Unit
    ) {
        val id = message.getMap("rsc")?.get("id") as? String
        Logger.debug { "Received RSC of saveId: $id" }

        val reponseMsg =
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

        send(PIOSerializer.serialize(reponseMsg))
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