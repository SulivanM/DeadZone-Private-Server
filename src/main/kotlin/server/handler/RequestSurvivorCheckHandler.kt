package server.handler

import context.ServerContext
import context.requirePlayerContext
import core.model.game.data.Survivor
import server.messaging.HandlerContext
import server.messaging.NetworkMessage
import server.messaging.SocketMessage
import server.messaging.SocketMessageHandler
import server.protocol.PIOSerializer
import common.Logger
import common.Time
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
        Unit
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
            level = 1,
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
            "voice": "${srv.voice}",
            "level": ${srv.level},
            "xp": ${srv.xp}
        }
        """.trimIndent()
    }

    val maleNames = setOf(
        "Tony Miller", "Peter Lawson", "Bruce Carter", "Clark Hayes", "Steve Morgan",
        "Luke Harrison", "Rick Sanders", "Joel Thompson", "Arthur Bennett", "John Reed",
        "Ethan Collins", "Leon Price", "Gordon Wallace", "Nathan Brooks", "Cloud Anderson",
        "Ryan Matthews", "Michael Turner", "David Collins", "James Parker", "Trevor Simmons"
    )

    val femaleNames = setOf(
        "Laras Croft", "Jill Harper", "Claire Bennett", "Ada Collins", "Ellie Williams",
        "Tifa Lawson", "Aerith Sullivan", "Hermione Blake", "Hinata Kimura", "Sarah Connor",
        "Carol Dawson", "Natasha Romanoff", "Selina Moore", "Sakura Tanaka", "Asuka Saito",
        "Yuna Fraser", "Anna Reynolds", "Jang Minji", "Harley Evans", "Emily Brooks"
    )
}
