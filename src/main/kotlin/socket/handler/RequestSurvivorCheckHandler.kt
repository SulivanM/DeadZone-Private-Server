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

        return Survivor(
            firstName = if (gender == "male") maleFirstNames.random() else femaleFirstNames.random(),
            lastName = if (gender == "male") maleLastNames.random() else femaleLastNames.random(),
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

    // popular culture names
    val maleFirstNames = setOf(
        "Mario", "Cloud", "Link", "Arthur", "Luffy",
        "Goku", "Tony", "Peter", "Jesse", "Neo",
        "Ash", "Sonic", "Leon", "Ezio", "Shinji",
        "Alucard", "Kratos", "Steve", "Jin", "Nathan"
    )

    val maleLastNames = setOf(
        "Skywalker", "Kenobi", "Potter", "Wayne", "Kent",
        "Stark", "Ryu", "Pinkman", "Strife", "Redfield",
        "Drake", "Sakai", "Morgan", "Elric", "Hiraga",
        "Tsukino", "Uzumaki", "Kurosaki", "Joestar", "Belcher"
    )

    val femaleFirstNames = setOf(
        "Zelda", "Lara", "Tifa", "Aerith", "Sakura",
        "Jill", "Ciri", "Hermione", "Leia", "Yuna",
        "Samus", "Ada", "Mikasa", "Hinata", "Cortana",
        "Ellie", "Rinoa", "Bulma", "Korra", "Judy"
    )

    val femaleLastNames = setOf(
        "Croft", "Lockhart", "Valentine", "Tsukino", "Hikari",
        "Organa", "Potter", "Forrester", "Kasugano", "Amane",
        "Gainsborough", "Shepard", "Takanashi", "Fairchild", "Alcott",
        "Valkyrie", "Nishimiya", "Sato", "Ravenwood", "Kusanagi"
    )
}
