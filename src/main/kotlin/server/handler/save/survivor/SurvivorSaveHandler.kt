package server.handler.save.survivor

import context.requirePlayerContext
import core.metadata.model.PlayerFlags
import core.model.game.data.HumanAppearance
import core.model.game.data.Survivor
import core.model.game.data.SurvivorClassConstants_Constants
import core.model.game.data.SurvivorLoadoutEntry
import core.survivor.model.injury.Injury
import core.survivor.InjuryService
import dev.deadzone.core.model.game.data.secondsLeftToEnd
import dev.deadzone.socket.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.survivor.response.PlayerCustomResponse
import server.handler.save.survivor.response.SurvivorEditResponse
import server.handler.save.survivor.response.SurvivorRenameResponse
import server.handler.save.survivor.response.SurvivorClassResponse
import server.handler.save.survivor.response.SurvivorLoadoutResponse
import server.handler.save.survivor.response.SurvivorInjurySpeedUpResponse
import server.handler.save.survivor.response.SurvivorReassignSpeedUpResponse
import server.handler.save.survivor.response.SurvivorInjureResponse
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import utils.JSON
import utils.LogConfigSocketToClient
import utils.Logger
import utils.SpeedUpCostCalculator

class SurvivorSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.SURVIVOR_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId

        when (type) {
            SaveDataMethod.SURVIVOR_CLASS -> {
                val survivorId = data["survivorId"] as? String
                val classId = data["classId"] as? String

                if (survivorId == null || classId == null) {
                    val responseJson = JSON.encode(
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
                    val responseJson = JSON.encode(
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
                    JSON.encode(SurvivorClassResponse(success = true))
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to update survivor class: ${updateResult.exceptionOrNull()?.message}" }
                    JSON.encode(
                        SurvivorClassResponse(success = false, error = "update_failed")
                    )
                }
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.SURVIVOR_OFFENCE_LOADOUT -> {
                val loadoutDataList = (data as? List<*>) ?: (data["data"] as? List<*>)

                if (loadoutDataList == null) {
                    val responseJson = JSON.encode(
                        SurvivorLoadoutResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                if (playerObjects == null) {
                    val responseJson = JSON.encode(
                        SurvivorLoadoutResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val updatedLoadouts = mutableMapOf<String, SurvivorLoadoutEntry>()
                val bindItemIds = mutableListOf<String>()

                for (loadoutData in loadoutDataList) {
                    val loadoutMap = loadoutData as? Map<*, *> ?: continue
                    val survivorId = loadoutMap["id"] as? String ?: continue
                    val weaponId = (loadoutMap["weapon"] ?: loadoutMap["w"] ?: "") as? String ?: ""
                    val gear1Id = (loadoutMap["gearPassive"] ?: loadoutMap["g1"] ?: "") as? String ?: ""
                    val gear2Id = (loadoutMap["gearActive"] ?: loadoutMap["g2"] ?: "") as? String ?: ""

                    updatedLoadouts[survivorId] = SurvivorLoadoutEntry(
                        weapon = weaponId,
                        gear1 = gear1Id,
                        gear2 = gear2Id
                    )

                    if (weaponId.isNotEmpty()) bindItemIds.add(weaponId)
                    if (gear1Id.isNotEmpty()) bindItemIds.add(gear1Id)
                    if (gear2Id.isNotEmpty()) bindItemIds.add(gear2Id)
                }

                val updatedPlayerObjects = playerObjects.copy(offenceLoadout = updatedLoadouts)
                serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

                val responseJson = JSON.encode(
                    SurvivorLoadoutResponse(success = true, bind = bindItemIds)
                )
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.SURVIVOR_DEFENCE_LOADOUT -> {
                val loadoutDataList = (data as? List<*>) ?: (data["data"] as? List<*>)

                if (loadoutDataList == null) {
                    val responseJson = JSON.encode(
                        SurvivorLoadoutResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                if (playerObjects == null) {
                    val responseJson = JSON.encode(
                        SurvivorLoadoutResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val updatedLoadouts = mutableMapOf<String, SurvivorLoadoutEntry>()
                val bindItemIds = mutableListOf<String>()

                for (loadoutData in loadoutDataList) {
                    val loadoutMap = loadoutData as? Map<*, *> ?: continue
                    val survivorId = loadoutMap["id"] as? String ?: continue
                    val weaponId = (loadoutMap["weapon"] ?: loadoutMap["w"] ?: "") as? String ?: ""
                    val gear1Id = (loadoutMap["gearPassive"] ?: loadoutMap["g1"] ?: "") as? String ?: ""
                    val gear2Id = (loadoutMap["gearActive"] ?: loadoutMap["g2"] ?: "") as? String ?: ""

                    updatedLoadouts[survivorId] = SurvivorLoadoutEntry(
                        weapon = weaponId,
                        gear1 = gear1Id,
                        gear2 = gear2Id
                    )

                    if (weaponId.isNotEmpty()) bindItemIds.add(weaponId)
                    if (gear1Id.isNotEmpty()) bindItemIds.add(gear1Id)
                    if (gear2Id.isNotEmpty()) bindItemIds.add(gear2Id)
                }

                val updatedPlayerObjects = playerObjects.copy(defenceLoadout = updatedLoadouts)
                serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

                val responseJson = JSON.encode(
                    SurvivorLoadoutResponse(success = true, bind = bindItemIds)
                )
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.SURVIVOR_CLOTHING_LOADOUT -> {
                val loadoutDataMap = data as? Map<*, *>

                if (loadoutDataMap == null) {
                    val responseJson = JSON.encode(
                        SurvivorLoadoutResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val svc = serverContext.requirePlayerContext(playerId).services
                val bindItemIds = mutableListOf<String>()
                val updatedSurvivors = mutableListOf<Survivor>()

                for (survivor in svc.survivor.getAllSurvivors()) {
                    val survivorData = loadoutDataMap[survivor.id] as? Map<*, *>

                    if (survivorData != null) {
                        val newAccessories = mutableMapOf<String, String>()
                        for ((slotIndex, itemId) in survivorData) {
                            val slotKey = slotIndex.toString()
                            val itemIdStr = itemId as? String ?: continue
                            if (itemIdStr.isNotEmpty()) {
                                newAccessories[slotKey] = itemIdStr
                                bindItemIds.add(itemIdStr)
                            }
                        }
                        updatedSurvivors.add(survivor.copy(accessories = newAccessories))
                    } else {
                        updatedSurvivors.add(survivor)
                    }
                }

                val updateResult = svc.survivor.updateSurvivors(updatedSurvivors)

                val responseJson = if (updateResult.isSuccess) {
                    JSON.encode(
                        SurvivorLoadoutResponse(success = true, bind = bindItemIds)
                    )
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to update survivor clothing: ${updateResult.exceptionOrNull()?.message}" }
                    JSON.encode(
                        SurvivorLoadoutResponse(success = false)
                    )
                }
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.SURVIVOR_INJURY_SPEED_UP -> {
                val survivorId = data["id"] as? String
                val injuryId = data["injuryId"] as? String
                val option = data["option"] as? String

                if (survivorId == null || injuryId == null || option == null) {
                    val responseJson = JSON.encode(
                        SurvivorInjurySpeedUpResponse(error = "Missing parameters", success = false, cost = 0)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                Logger.info(LogConfigSocketToClient) { "'SURVIVOR_INJURY_SPEED_UP' message for survivorId=$survivorId, injuryId=$injuryId with option=$option" }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val playerFuel = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                val survivor = svc.survivor.getAllSurvivors().find { it.id == survivorId }
                if (survivor == null) {
                    Logger.warn(LogConfigSocketToClient) { "Survivor not found for survivorId=$survivorId" }
                    val responseJson = JSON.encode(
                        SurvivorInjurySpeedUpResponse(error = "Survivor not found", success = false, cost = 0)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                val injury = survivor.injuries.find { it.id == injuryId }
                if (injury == null || injury.timer == null) {
                    Logger.warn(LogConfigSocketToClient) { "Injury not found or has no timer for injuryId=$injuryId" }
                    val responseJson = JSON.encode(
                        SurvivorInjurySpeedUpResponse(error = "Injury not found", success = false, cost = 0)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                val secondsRemaining = injury.timer.secondsLeftToEnd()
                val cost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)

                val response: SurvivorInjurySpeedUpResponse
                var resourceResponse: core.model.game.data.GameResources? = null

                if (playerFuel < cost) {
                    response = SurvivorInjurySpeedUpResponse(error = notEnoughCoinsErrorId, success = false, cost = cost)
                } else {
                    
                    val updateResult = svc.survivor.updateSurvivor(survivorId) { currentSurvivor ->
                        currentSurvivor.copy(
                            injuries = currentSurvivor.injuries.filter { it.id != injuryId }
                        )
                    }

                    if (updateResult.isSuccess) {
                        svc.compound.updateResource { resource ->
                            resourceResponse = resource.copy(cash = playerFuel - cost)
                            resourceResponse
                        }
                        response = SurvivorInjurySpeedUpResponse(error = "", success = true, cost = cost)
                    } else {
                        Logger.error(LogConfigSocketToClient) { "Failed to update survivor injuries: ${updateResult.exceptionOrNull()?.message}" }
                        response = SurvivorInjurySpeedUpResponse(error = "", success = false, cost = 0)
                    }
                }

                val responseJson = JSON.encode(response)
                val resourceResponseJson = JSON.encode(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
            }

            SaveDataMethod.SURVIVOR_RENAME -> {
                val survivorId = data["id"] as? String
                val name = data["name"] as? String

                if (survivorId == null || name == null) {
                    val responseJson = JSON.encode(
                        SurvivorRenameResponse(success = false, error = "name_invalid")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val trimmedName = name.trim()

                if (trimmedName.length < 3) {
                    val responseJson = JSON.encode(
                        SurvivorRenameResponse(success = false, error = "name_short")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                if (trimmedName.length > 30) {
                    val responseJson = JSON.encode(
                        SurvivorRenameResponse(success = false, error = "name_long")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                if (!trimmedName.matches(Regex("^[a-zA-Z0-9 ]+$"))) {
                    val responseJson = JSON.encode(
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
                    JSON.encode(
                        SurvivorRenameResponse(success = true, name = trimmedName, id = survivorId)
                    )
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to update survivor: ${updateResult.exceptionOrNull()?.message}" }
                    JSON.encode(
                        SurvivorRenameResponse(success = false, error = "name_invalid")
                    )
                }
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.SURVIVOR_REASSIGN -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_REASSIGN' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_REASSIGN_SPEED_UP -> {
                val survivorId = data["id"] as? String
                val option = data["option"] as? String

                if (survivorId == null || option == null) {
                    val responseJson = JSON.encode(
                        SurvivorReassignSpeedUpResponse(error = "Missing parameters", success = false, cost = 0)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                Logger.info(LogConfigSocketToClient) { "'SURVIVOR_REASSIGN_SPEED_UP' message for survivorId=$survivorId with option=$option" }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val playerFuel = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                val survivor = svc.survivor.getAllSurvivors().find { it.id == survivorId }
                if (survivor == null) {
                    Logger.warn(LogConfigSocketToClient) { "Survivor not found for survivorId=$survivorId" }
                    val responseJson = JSON.encode(
                        SurvivorReassignSpeedUpResponse(error = "Survivor not found", success = false, cost = 0)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                if (survivor.reassignTimer == null) {
                    Logger.warn(LogConfigSocketToClient) { "Survivor has no reassign timer for survivorId=$survivorId" }
                    val responseJson = JSON.encode(
                        SurvivorReassignSpeedUpResponse(error = "No reassign timer", success = false, cost = 0)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                val secondsRemaining = survivor.reassignTimer.secondsLeftToEnd()
                val cost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)

                val response: SurvivorReassignSpeedUpResponse
                var resourceResponse: core.model.game.data.GameResources? = null

                if (playerFuel < cost) {
                    response = SurvivorReassignSpeedUpResponse(error = notEnoughCoinsErrorId, success = false, cost = cost)
                } else {
                    val updateResult = svc.survivor.updateSurvivor(survivorId) { currentSurvivor ->
                        currentSurvivor.copy(reassignTimer = null)
                    }

                    if (updateResult.isSuccess) {
                        svc.compound.updateResource { resource ->
                            resourceResponse = resource.copy(cash = playerFuel - cost)
                            resourceResponse
                        }
                        response = SurvivorReassignSpeedUpResponse(error = "", success = true, cost = cost)
                    } else {
                        Logger.error(LogConfigSocketToClient) { "Failed to update survivor reassign timer: ${updateResult.exceptionOrNull()?.message}" }
                        response = SurvivorReassignSpeedUpResponse(error = "", success = false, cost = 0)
                    }
                }

                val responseJson = JSON.encode(response)
                val resourceResponseJson = JSON.encode(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
            }

            SaveDataMethod.SURVIVOR_BUY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'SURVIVOR_BUY' message [not implemented]" }
            }

            SaveDataMethod.SURVIVOR_INJURE -> {
                val survivorId = data["id"] as? String
                val severityGroup = data["s"] as? String
                val cause = data["c"] as? String
                val force = (data["f"] as? Boolean) ?: false
                val isCritical = (data["cr"] as? Boolean) ?: false

                if (survivorId == null || severityGroup == null || cause == null) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                Logger.info(LogConfigSocketToClient) { 
                    "SURVIVOR_INJURE: survivorId=$survivorId, severity=$severityGroup, cause=$cause, force=$force, critical=$isCritical" 
                }

                if (!InjuryService.isValidSeverityGroup(severityGroup) || !InjuryService.isValidCause(cause)) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                val svc = serverContext.requirePlayerContext(playerId).services

                val survivor = svc.survivor.getAllSurvivors().find { it.id.equals(survivorId, ignoreCase = true) }
                if (survivor == null) {
                    Logger.warn(LogConfigSocketToClient) { "Survivor not found: $survivorId" }
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                val injury = InjuryService.generateInjury(severityGroup, cause, force, isCritical)

                if (injury == null) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = true, srv = survivor.id, inj = null)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                val updateResult = svc.survivor.updateSurvivor(survivor.id) { currentSurvivor ->
                    currentSurvivor.copy(
                        injuries = currentSurvivor.injuries + injury
                    )
                }

                val responseJson = if (updateResult.isSuccess) {
                    Logger.info(LogConfigSocketToClient) { 
                        "Injury added: ${injury.type} (${injury.severity}) at ${injury.location} for survivor ${survivor.id}" 
                    }
                    JSON.encode(
                        SurvivorInjureResponse(success = true, srv = survivor.id, inj = injury)
                    )
                } else {
                    Logger.error(LogConfigSocketToClient) { 
                        "Failed to add injury to survivor: ${updateResult.exceptionOrNull()?.message}" 
                    }
                    JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                }

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.SURVIVOR_ENEMY_INJURE -> {
                val survivorId = data["id"] as? String
                val severityGroup = data["s"] as? String
                val cause = data["c"] as? String
                val force = (data["f"] as? Boolean) ?: false
                val isCritical = (data["cr"] as? Boolean) ?: false

                if (survivorId == null || severityGroup == null || cause == null) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                Logger.info(LogConfigSocketToClient) { 
                    "SURVIVOR_ENEMY_INJURE: survivorId=$survivorId, severity=$severityGroup, cause=$cause, force=$force, critical=$isCritical" 
                }

                if (!InjuryService.isValidSeverityGroup(severityGroup) || !InjuryService.isValidCause(cause)) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                val svc = serverContext.requirePlayerContext(playerId).services

                val survivor = svc.survivor.getAllSurvivors().find { it.id.equals(survivorId, ignoreCase = true) }
                if (survivor == null) {
                    Logger.warn(LogConfigSocketToClient) { "Enemy survivor not found: $survivorId" }
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                val injury = InjuryService.generateInjury(severityGroup, cause, force, isCritical)

                if (injury == null) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = true, srv = survivor.id, inj = null)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                val updateResult = svc.survivor.updateSurvivor(survivor.id) { currentSurvivor ->
                    currentSurvivor.copy(
                        injuries = currentSurvivor.injuries + injury
                    )
                }

                val responseJson = if (updateResult.isSuccess) {
                    Logger.info(LogConfigSocketToClient) { 
                        "Enemy injury added: ${injury.type} (${injury.severity}) at ${injury.location} for survivor ${survivor.id}" 
                    }
                    JSON.encode(
                        SurvivorInjureResponse(success = true, srv = survivor.id, inj = injury)
                    )
                } else {
                    Logger.error(LogConfigSocketToClient) { 
                        "Failed to add injury to enemy survivor: ${updateResult.exceptionOrNull()?.message}" 
                    }
                    JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                }

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
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
                    val responseJson = JSON.encode(
                        PlayerCustomResponse(error = "Nickname not allowed")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val svc = serverContext.requirePlayerContext(playerId).services

                val flagsResult = svc.playerObjectMetadata.updatePlayerFlags(
                    flags = PlayerFlags.create(nicknameVerified = true)
                )
                if (flagsResult.isFailure) {
                    Logger.error(LogConfigSocketToClient) { "Failed to update player flags: ${flagsResult.exceptionOrNull()?.message}" }
                    val responseJson = JSON.encode(
                        PlayerCustomResponse(error = "db_error")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val nicknameResult = svc.playerObjectMetadata.updatePlayerNickname(nickname = title)
                if (nicknameResult.isFailure) {
                    Logger.error(LogConfigSocketToClient) { "Failed to update nickname: ${nicknameResult.exceptionOrNull()?.message}" }
                    val responseJson = JSON.encode(
                        PlayerCustomResponse(error = "db_error")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val survivorResult = svc.survivor.updateSurvivor(srvId = svc.survivor.survivorLeaderId) {
                    svc.survivor.getSurvivorLeader().copy(
                        title = title,
                        firstName = title.split(" ").firstOrNull() ?: "",
                        lastName = title.split(" ").getOrNull(1) ?: "",
                        voice = voice,
                        gender = gender,
                        appearance = appearance
                    )
                }
                if (survivorResult.isFailure) {
                    Logger.error(LogConfigSocketToClient) { "Failed to update survivor: ${survivorResult.exceptionOrNull()?.message}" }
                    val responseJson = JSON.encode(
                        PlayerCustomResponse(error = "db_error")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val responseJson = JSON.encode(PlayerCustomResponse())

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.SURVIVOR_EDIT -> {
                val survivorId = data["id"] as? String ?: return
                val ap = data["ap"] as? Map<*, *>
                val gender = data["g"] as? String
                val voice = data["v"] as? String

                Logger.info(LogConfigSocketToClient) { "Editing survivor id=$survivorId, ap=$ap, gender=$gender, voice=$voice" }

                val svc = serverContext.requirePlayerContext(playerId).services

                val updateResult = svc.survivor.updateSurvivor(srvId = survivorId) { currentSurvivor ->
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

                val responseJson = if (updateResult.isSuccess) {
                    JSON.encode(SurvivorEditResponse(success = true))
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to update survivor: ${updateResult.exceptionOrNull()?.message}" }
                    JSON.encode(SurvivorEditResponse(success = false))
                }
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
