package socket.handler

import context.ServerContext
import context.requirePlayerContext
import core.model.game.data.Survivor
import dev.deadzone.socket.messaging.HandlerContext
import socket.messaging.NetworkMessage
import socket.messaging.SocketMessage
import socket.messaging.SocketMessageHandler
import socket.protocol.PIOSerializer
import utils.Logger
import utils.Time
import kotlin.collections.random
import kotlin.random.Random

/**
 * Handle `rsc` message by:
 *
 * 1. Sending a reponse in JSON with success set to true
 *
 */
class RequestSurvivorCheckHandler(private val serverContext: ServerContext) : SocketMessageHandler {
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
                """{"success": true}""".trimIndent() // response
            )

        val newSrv = generateSurvivor()
        val newSurvivorMsg = listOf(NetworkMessage.SURVIVOR_NEW, generateNewSurvivorJson(newSrv))

        send(PIOSerializer.serialize(responseMsg))
        send(PIOSerializer.serialize(newSurvivorMsg))

        val svc = serverContext.requirePlayerContext(connection.playerId).services
        svc.survivor.addNewSurvivor(newSrv)
    }

    private fun generateSurvivor(): Survivor {
        val gender = if (Random.nextBoolean()) "male" else "female"
        val maleVoices = setOf("white-m", "black-m", "latino-m", "asian-m")
        val femaleVoices = setOf("white-f", "black-f", "latino-f")
        val name = (if (gender == "male") maleNames.random() else femaleNames.random()).split(" ")

        return Survivor(
            firstName = name[0],
            lastName = name[1],
            gender = gender,
            classId = "unassigned",
            voice = if (gender == "male") maleVoices.random() else femaleVoices.random(),
            title = "",
            morale = emptyMap(),
            injuries = emptyList(),
            level = 0,
            xp = 0,
            missionId = null,
            assignmentId = null,
            accessories = emptyMap(),
            maxClothingAccessories = 1,
        )
    }

    private fun generateNewSurvivorJson(srv: Survivor): String {
        return """
        {
            "id": "${srv.id}",
            "title": "${srv.title}",
            "firstName": "${srv.firstName}",
            "lastName": "${srv.lastName}",
            "gender": "${srv.gender}",
            "classId": "${srv.classId}",
            "voice": "${srv.voice}"
        }
        """.trimIndent()
    }

    // popular culture some troll names
    val maleNames = setOf(
        "Tony Stark", "Peter Parker", "Bruce Wayne", "Clark Kent", "Steve Rogers",
        "Luke Skywalker", "Genshin Impact", "Rick Roll", "Joel Miller", "Arthur Morgan",
        "John Wick", "Ethan Winters", "Leon Kennedy", "Gordon Freeman", "Nathan Drake",
        "Cloud Strife", "Uzumaki Naruto", "Zombie Dinner", "Jesse Pinkman", "Trevor Philips"
    )

    val femaleNames = setOf(
        "Lara Croft", "Jill Valentine", "Claire Redfield", "Ada Wong", "Ellie Williams",
        "Tifa Lockhart", "Aerith Gainsborough", "Hermione Granger", "Hinata Hyuga", "Sarah Connor",
        "Genshin Impact", "Carol Danvers", "Tasty Brain", "Natasha Romanoff", "Selina Kyle",
        "Sakura Haruno", "Asuka Langley", "Yuna Braska", "Jang Wonyoung", "Harley Quinn"
    )
}
