package dev.deadzone.socket.handler.save.survivor

import dev.deadzone.context.GlobalContext
import dev.deadzone.context.ServerContext
import dev.deadzone.context.requirePlayerContext
import dev.deadzone.core.model.data.PlayerFlags
import dev.deadzone.core.model.game.data.HumanAppearance
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.buildMsg
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.handler.save.survivor.response.PlayerCustomResponse
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.socket.protocol.PIOSerializer
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class SurvivorSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.SURVIVOR_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        val playerId = connection.playerId

        when (type) {
            SaveDataMethod.SURVIVOR_CLASS -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_CLASS' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_OFFENCE_LOADOUT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_OFFENCE_LOADOUT' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_DEFENCE_LOADOUT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_DEFENCE_LOADOUT' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_CLOTHING_LOADOUT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_CLOTHING_LOADOUT' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_INJURY_SPEED_UP -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_INJURY_SPEED_UP' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_RENAME -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_RENAME' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_REASSIGN -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_REASSIGN' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_REASSIGN_SPEED_UP -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_REASSIGN_SPEED_UP' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_BUY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_BUY' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_INJURE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_INJURE' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_ENEMY_INJURE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_ENEMY_INJURE' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_HEAL_INJURY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_HEAL_INJURY' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_HEAL_ALL -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_HEAL_ALL' message [not implemented]" }
            }

            SaveDataMethod.PLAYER_CUSTOM -> {
                val ap = data["ap"] as? Map<*, *> ?: return
                val title = data["name"] as? String ?: return
                val voice = data["v"] as? String ?: return
                val gender = data["g"] as? String ?: return
                val appearance = HumanAppearance.parse(ap)
                if (appearance == null) {
                    Logger.error(LogConfigSocketToClient) { "Failed to parse rawappearance=$ap" }
                    return
                }

                val bannedNicknames = listOf("dick")
                val nicknameNotAllowed = bannedNicknames.any { bannedWord ->
                    title.contains(bannedWord)
                }
                if (nicknameNotAllowed) {
                    val responseJson = GlobalContext.json.encodeToString(
                        PlayerCustomResponse(error = "Nickname not allowed")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val svc = serverContext.requirePlayerContext(playerId).services

                svc.playerObjectMetadata.updatePlayerFlags(
                    flags = PlayerFlags.create(nicknameVerified = true)
                )

                svc.playerObjectMetadata.updatePlayerNickname(nickname = title)

                svc.survivor.updateSurvivor(srvId = svc.survivor.survivorLeaderId) {
                    svc.survivor.getSurvivorLeader().copy(
                        title = title,
                        firstName = title.split(" ").firstOrNull() ?: "",
                        lastName = title.split(" ").getOrNull(1) ?: "",
                        voice = voice,
                        gender = gender,
                        appearance = appearance
                    )
                }

                val responseJson = GlobalContext.json.encodeToString(PlayerCustomResponse())

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.SURVIVOR_EDIT -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_EDIT' message [not implemented]" }
            }

            SaveDataMethod.NAMES -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'NAMES' message [not implemented]" }
            }

            SaveDataMethod.RESET_LEADER -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'RESET_LEADER' message [not implemented]" }
            }
        }
    }
}
