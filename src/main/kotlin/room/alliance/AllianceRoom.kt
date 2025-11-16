package room.alliance

import api.message.Message
import context.ServerContext
import room.Room
import room.RoomType
import server.core.Connection
import common.JSON
import common.Logger
import common.toJsonElement

/**
 * Room spécialisée pour les alliances
 * Basé sur AllianceSystem.as du client AS3
 */
class AllianceRoom(
    roomId: String,
    val allianceId: String,
    private val serverContext: ServerContext,
    visible: Boolean = true,
    roomData: Map<String, Any> = emptyMap(),
    ownerId: String? = null,
    isDevRoom: Boolean = false,
    maxPlayers: Int = 100
) : Room(
    roomId = roomId,
    roomType = RoomType.ALLIANCE,
    visible = visible,
    roomData = roomData,
    ownerId = ownerId,
    isDevRoom = isDevRoom,
    maxPlayers = maxPlayers
) {
    /**
     * Appelé quand un joueur rejoint la room alliance
     * Note: Le message allianceData sera envoyé par sendAllianceDataToPlayer après joinresult
     */
    override fun onPlayerJoined(userId: String, connection: Connection) {
        Logger.debug { "AllianceRoom: Player $userId joined alliance room $allianceId" }
    }

    /**
     * Envoie les données initiales de l'alliance au joueur
     * Appelé par JoinHandler après l'envoi de joinresult
     */
    suspend fun sendAllianceDataToPlayer(userId: String) {
        val connection = getConnection(userId)
        if (connection == null) {
            Logger.error { "AllianceRoom: Connection not found for player $userId" }
            return
        }
        sendAllianceData(userId, connection)
    }

    /**
     * Envoie les données de l'alliance au joueur
     * Format attendu par le client AS3 (AllianceSystem.as ligne 840-894):
     * Message "allianceData" avec un JSON contenant:
     * - id: ID de l'alliance
     * - name: Nom de l'alliance
     * - tag: Tag de l'alliance
     * - members: Liste des membres
     * - messages: Messages de l'alliance
     * - rankPrivs: Privilèges des rangs (JSON stringifié)
     * - canContribute: Peut contribuer au round
     * - effectCost: Coût des effets
     * - round data: roundNum, roundActive, roundEnd
     */
    private suspend fun sendAllianceData(userId: String, connection: Connection) {
        try {
            // Charger les données de l'alliance depuis la base de données
            val alliance = serverContext.db.loadAlliance(allianceId)
            if (alliance == null) {
                Logger.error { "AllianceRoom: Alliance $allianceId not found in database" }
                // Envoyer un message de rejet de connexion
                val rejectMsg = Message("connRejected")
                connection.send(rejectMsg)
                return
            }

            // Charger les membres de l'alliance
            val members = serverContext.db.getAllianceMembers(allianceId)

            // Vérifier que le joueur est bien membre de cette alliance
            val playerMember = members.find { it.playerId == userId }
            if (playerMember == null) {
                Logger.error { "AllianceRoom: Player $userId is not a member of alliance $allianceId" }
                // Envoyer un message de rejet de connexion
                val rejectMsg = Message("connRejected")
                connection.send(rejectMsg)
                return
            }

            // Charger les messages de l'alliance
            val allianceMessages = serverContext.db.getAllianceMessages(allianceId)

            // Construire les données des membres pour le client
            val membersData = members.map { member ->
                mapOf(
                    "id" to member.playerId,
                    "nickName" to member.nickname,
                    "rank" to member.rank.toInt(),
                    "joinDate" to member.joindate,
                    "isOnline" to member.online,
                    "level" to member.level,
                    "points" to member.points.toInt(),
                    "tokens" to member.tokens.toInt()
                )
            }

            // Construire les données des messages pour le client
            val messagesData = allianceMessages.map { msg ->
                mapOf(
                    "id" to msg.id,
                    "subject" to msg.title,
                    "body" to msg.message,
                    "posterId" to msg.playerId,
                    "posterNickName" to msg.author,
                    "posterRank" to 0,
                    "date" to msg.date
                )
            }

            // Construire les privilèges des rangs (JSON stringifié)
            val rankPrivs = mapOf(
                "0" to mapOf("name" to "Founder", "priv" to 255),
                "1" to mapOf("name" to "Leader", "priv" to 127),
                "2" to mapOf("name" to "Officer", "priv" to 63),
                "3" to mapOf("name" to "Member", "priv" to 7),
                "4" to mapOf("name" to "Recruit", "priv" to 3)
            )

            // Construire les données du round actuel
            val currentTime = System.currentTimeMillis()

            // Construire l'objet allianceData complet
            val allianceData = buildMap<String, Any> {
                put("id", alliance.allianceDataSummary.allianceId ?: "")
                put("name", alliance.allianceDataSummary.name ?: "")
                put("tag", alliance.allianceDataSummary.tag ?: "")
                put("members", membersData)
                put("messages", messagesData)
                put("rankPrivs", JSON.encode(rankPrivs.toJsonElement()))
                put("roundNum", 0)
                put("roundActive", currentTime)
                put("roundEnd", currentTime + 7 * 24 * 60 * 60 * 1000) // 7 jours
                put("canContribute", true)
                put("effectCost", 0)
                put("points", alliance.allianceDataSummary.points ?: 0)
                put("tokens", alliance.tokens ?: 0)
            }

            // Encoder en JSON et envoyer
            val allianceDataJson = JSON.encode(allianceData.toJsonElement())

            val message = Message("allianceData")
            message.add(allianceDataJson)

            connection.send(message)
            Logger.debug { "AllianceRoom: Sent allianceData to player $userId" }

        } catch (e: Exception) {
            Logger.error { "AllianceRoom: Error sending alliance data: ${e.message}" }
            e.printStackTrace()

            // Envoyer un message de rejet de connexion en cas d'erreur
            val rejectMsg = Message("connRejected")
            connection.send(rejectMsg)
        }
    }

    override fun onPlayerLeft(userId: String, connection: Connection) {
        Logger.debug { "AllianceRoom: Player $userId left alliance room $allianceId" }
    }
}
