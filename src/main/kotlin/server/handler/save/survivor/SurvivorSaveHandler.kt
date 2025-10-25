package server.handler.save.survivor

import context.GlobalContext
import context.requirePlayerContext
import core.metadata.model.PlayerFlags
import core.model.game.data.HumanAppearance
import core.model.game.data.SurvivorClassConstants_Constants
import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.survivor.response.PlayerCustomResponse
import server.handler.save.survivor.response.SurvivorEditResponse
import server.handler.save.survivor.response.SurvivorRenameResponse
import server.handler.save.survivor.response.SurvivorClassResponse
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import utils.LogConfigSocketToClient
import utils.Logger

class SurvivorSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.SURVIVOR_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId

        when (type) {
            SaveDataMethod.SURVIVOR_CLASS -> {
                val survivorId = data["survivorId"] as? String
                val classId = data["classId"] as? String

                if (survivorId == null || classId == null) {
                    val responseJson = GlobalContext.json.encodeToString(
                        SurvivorClassResponse(success = false, error = "invalid_params")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val validClasses = listOf(
                    SurvivorClassConstants_Constants.FIGHTER.value,
                    SurvivorClassConstants_Constants.MEDIC.value,
                    SurvivorClassConstants_Constants.SCAVENGER.value,
                    SurvivorClassConstants_Constants.ENGINEER.value,
                    SurvivorClassConstants_Constants.RECON.value,
                    SurvivorClassConstants_Constants.UNASSIGNED.value
                )

                if (classId !in validClasses) {
                    val responseJson = GlobalContext.json.encodeToString(
                        SurvivorClassResponse(success = false, error = "invalid_class")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val svc = serverContext.requirePlayerContext(playerId).services

                val updateResult = svc.survivor.updateSurvivor(srvId = survivorId) { currentSurvivor ->
                    currentSurvivor.copy(classId = classId)
                }

                val responseJson = if (updateResult.isSuccess) {
                    GlobalContext.json.encodeToString(SurvivorClassResponse(success = true))
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to update survivor class: ${updateResult.exceptionOrNull()?.message}" }
                    GlobalContext.json.encodeToString(
                        SurvivorClassResponse(success = false, error = "update_failed")
                    )
                }
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
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
                val survivorId = data["id"] as? String
                val name = data["name"] as? String

                if (survivorId == null || name == null) {
                    val responseJson = GlobalContext.json.encodeToString(
                        SurvivorRenameResponse(success = false, error = "name_invalid")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val trimmedName = name.trim()

                if (trimmedName.length < 3) {
                    val responseJson = GlobalContext.json.encodeToString(
                        SurvivorRenameResponse(success = false, error = "name_short")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                if (trimmedName.length > 30) {
                    val responseJson = GlobalContext.json.encodeToString(
                        SurvivorRenameResponse(success = false, error = "name_long")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                if (!trimmedName.matches(Regex("^[a-zA-Z0-9 ]+$"))) {
                    val responseJson = GlobalContext.json.encodeToString(
                        SurvivorRenameResponse(success = false, error = "name_invalid")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val svc = serverContext.requirePlayerContext(playerId).services

                val updateResult = svc.survivor.updateSurvivor(srvId = survivorId) { currentSurvivor ->
                    currentSurvivor.copy(
                        title = trimmedName,
                        firstName = trimmedName.split(" ").firstOrNull() ?: trimmedName,
                        lastName = trimmedName.split(" ").getOrNull(1) ?: ""
                    )
                }

                val responseJson = if (updateResult.isSuccess) {
                    GlobalContext.json.encodeToString(
                        SurvivorRenameResponse(success = true, name = trimmedName, id = survivorId)
                    )
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to update survivor: ${updateResult.exceptionOrNull()?.message}" }
                    GlobalContext.json.encodeToString(
                        SurvivorRenameResponse(success = false, error = "name_invalid")
                    )
                }
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
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
                @Suppress("SENSELESS_COMPARISON")
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

                // TODO respond to DB failure
                svc.playerObjectMetadata.updatePlayerFlags(
                    flags = PlayerFlags.create(nicknameVerified = true)
                )

                // TODO respond to DB failure
                svc.playerObjectMetadata.updatePlayerNickname(nickname = title)

                // TODO respond to DB failure
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
                val survivorId = data["id"] as? String ?: return
                val ap = data["ap"] as? Map<*, *>
                val gender = data["g"] as? String
                val voice = data["v"] as? String

                Logger.info(LogConfigSocketToClient) { "Editing survivor id=$survivorId, ap=$ap, gender=$gender, voice=$voice" }

                val svc = serverContext.requirePlayerContext(playerId).services

                // TODO respond to DB failure
                svc.survivor.updateSurvivor(srvId = survivorId) { currentSurvivor ->
                    var updatedSurvivor = currentSurvivor

                    if (ap != null) {
                        val appearance = HumanAppearance.parse(ap)
                        @Suppress("SENSELESS_COMPARISON")
                        if (appearance != null) {
                            updatedSurvivor = updatedSurvivor.copy(appearance = appearance)
                        } else {
                            Logger.error(LogConfigSocketToClient) { "Failed to parse appearance=$ap" }
                        }
                    }

                    if (gender != null) {
                        updatedSurvivor = updatedSurvivor.copy(gender = gender)
                    }

                    if (voice != null) {
                        updatedSurvivor = updatedSurvivor.copy(voice = voice)
                    }

                    updatedSurvivor
                }

                val responseJson = GlobalContext.json.encodeToString(SurvivorEditResponse(success = true))
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
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