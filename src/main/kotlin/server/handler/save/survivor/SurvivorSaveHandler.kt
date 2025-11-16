package server.handler.save.survivor

import context.requirePlayerContext
import core.metadata.model.PlayerFlags
import core.model.game.data.Attributes
import core.model.game.data.HumanAppearance
import core.model.game.data.Survivor
import core.model.game.data.SurvivorClassConstants_Constants
import core.model.game.data.SurvivorLoadoutEntry
import core.survivor.model.injury.Injury
import dev.deadzone.core.model.game.data.secondsLeftToEnd
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.survivor.response.PlayerCustomResponse
import server.handler.save.survivor.response.SurvivorEditResponse
import server.handler.save.survivor.response.SurvivorRenameResponse
import server.handler.save.survivor.response.SurvivorClassResponse
import server.handler.save.survivor.response.SurvivorLoadoutResponse
import server.handler.save.survivor.response.SurvivorInjurySpeedUpResponse
import server.handler.save.survivor.response.SurvivorReassignSpeedUpResponse
import server.handler.save.survivor.response.SurvivorReassignResponse
import server.handler.save.survivor.response.SurvivorInjureResponse
import server.handler.save.survivor.response.SurvivorHealResponse
import server.handler.save.survivor.response.SurvivorBuyResponse
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import common.JSON
import common.LogConfigSocketError
import common.LogConfigSocketToClient
import common.Logger
import core.game.SpeedUpCostCalculator

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

                    // Parse gear2 (active gear) - can be a string or an object with {item, qty}
                    val gear2Data = loadoutMap["gearActive"] ?: loadoutMap["g2"]
                    val (gear2Id, gear2Qty) = when (gear2Data) {
                        is Map<*, *> -> {
                            val id = (gear2Data["item"] ?: gear2Data["id"] ?: "") as? String ?: ""
                            val qty = (gear2Data["qty"] ?: gear2Data["quantity"] ?: 1) as? Int ?: 1
                            id to qty
                        }
                        is String -> gear2Data to 1
                        else -> "" to 0
                    }

                    updatedLoadouts[survivorId] = SurvivorLoadoutEntry(
                        weapon = weaponId,
                        gear1 = gear1Id,
                        gear2 = gear2Id,
                        gear2_qty = gear2Qty
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

                    // Parse gear2 (active gear) - can be a string or an object with {item, qty}
                    val gear2Data = loadoutMap["gearActive"] ?: loadoutMap["g2"]
                    val (gear2Id, gear2Qty) = when (gear2Data) {
                        is Map<*, *> -> {
                            val id = (gear2Data["item"] ?: gear2Data["id"] ?: "") as? String ?: ""
                            val qty = (gear2Data["qty"] ?: gear2Data["quantity"] ?: 1) as? Int ?: 1
                            id to qty
                        }
                        is String -> gear2Data to 1
                        else -> "" to 0
                    }

                    updatedLoadouts[survivorId] = SurvivorLoadoutEntry(
                        weapon = weaponId,
                        gear1 = gear1Id,
                        gear2 = gear2Id,
                        gear2_qty = gear2Qty
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
                    // For injuries, we simply remove the injury on speedup (instant heal)
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
                
                // Send fuel update if resources changed (successful injury speed-up)
                resourceResponse?.let { res ->
                    sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                }
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
                val survivorId = data["id"] as? String
                val newClassId = data["classId"] as? String
                val buy = data["buy"] as? Boolean ?: false

                if (survivorId == null || newClassId == null) {
                    val responseJson = JSON.encode(
                        SurvivorReassignResponse(success = false, error = "invalid_params")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val validClasses = listOf(
                    SurvivorClassConstants_Constants.FIGHTER.value,
                    SurvivorClassConstants_Constants.MEDIC.value,
                    SurvivorClassConstants_Constants.SCAVENGER.value,
                    SurvivorClassConstants_Constants.ENGINEER.value,
                    SurvivorClassConstants_Constants.RECON.value
                )

                if (newClassId !in validClasses) {
                    val responseJson = JSON.encode(
                        SurvivorReassignResponse(success = false, error = "invalid_class")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val svc = serverContext.requirePlayerContext(playerId).services
                val survivor = svc.survivor.getAllSurvivors().find { it.id == survivorId }

                if (survivor == null) {
                    val responseJson = JSON.encode(
                        SurvivorReassignResponse(success = false, error = "survivor_not_found")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Check if survivor is on mission or assignment
                if (survivor.missionId != null || survivor.assignmentId != null) {
                    val responseJson = JSON.encode(
                        SurvivorReassignResponse(success = false, error = "survivor_busy")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val notEnoughCoinsErrorId = "55"
                var resourceResponse: core.model.game.data.GameResources? = null
                var reassignTimer: dev.deadzone.core.model.game.data.TimerData? = null

                if (buy) {
                    // If buy=true, instant reassignment for cash
                    val cost = survivor.level * 100
                    val playerCash = svc.compound.getResources().cash

                    if (playerCash < cost) {
                        val responseJson = JSON.encode(
                            SurvivorReassignResponse(success = false, error = notEnoughCoinsErrorId)
                        )
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                        return
                    }

                    // Deduct cost
                    svc.compound.updateResource { resource ->
                        resourceResponse = resource.copy(cash = playerCash - cost)
                        resourceResponse
                    }
                } else {
                    // If buy=false, create a timer based on survivor level
                    // Base time: 1 hour per level (3600 seconds)
                    val reassignTime = survivor.level * 3600
                    val timerId = common.UUID.new()

                    reassignTimer = dev.deadzone.core.model.game.data.TimerData(
                        start = System.currentTimeMillis(),
                        length = reassignTime.toLong(),
                        data = mapOf(
                            "id" to timerId,
                            "type" to "reassign",
                            "targetClass" to newClassId
                        )
                    )
                }

                // Reset to level 1 and change class (or set timer if not buying)
                val updateResult = svc.survivor.updateSurvivor(survivorId) { currentSurvivor ->
                    if (buy) {
                        // Instant reassignment
                        currentSurvivor.copy(
                            classId = newClassId,
                            level = 1,
                            xp = 0,
                            reassignTimer = null
                        )
                    } else {
                        // Set timer, don't change class yet
                        currentSurvivor.copy(
                            reassignTimer = reassignTimer
                        )
                    }
                }

                val responseJson = if (updateResult.isSuccess) {
                    if (buy) {
                        // Instant reassignment completed
                        JSON.encode(
                            SurvivorReassignResponse(
                                success = true,
                                id = survivorId,
                                classId = newClassId,
                                level = 1,
                                xp = 0,
                                timer = null
                            )
                        )
                    } else {
                        // Reassignment timer started
                        JSON.encode(
                            SurvivorReassignResponse(
                                success = true,
                                id = survivorId,
                                classId = survivor.classId,  // Keep current class until timer ends
                                level = survivor.level,      // Keep current level until timer ends
                                xp = survivor.xp,            // Keep current xp until timer ends
                                timer = reassignTimer
                            )
                        )
                    }
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to reassign survivor: ${updateResult.exceptionOrNull()?.message}" }
                    JSON.encode(
                        SurvivorReassignResponse(success = false, error = "update_failed")
                    )
                }

                val msg = if (resourceResponse != null) {
                    buildMsg(saveId, responseJson, JSON.encode(resourceResponse))
                } else {
                    buildMsg(saveId, responseJson)
                }
                send(PIOSerializer.serialize(msg))
                
                // Send fuel update if resources changed (successful reassign with buy)
                resourceResponse?.let { res ->
                    sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                }
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
                    // Remove the reassign timer
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
                
                // Send fuel update if resources changed (successful reassign speed-up)
                resourceResponse?.let { res ->
                    sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                }
            }

            SaveDataMethod.SURVIVOR_BUY -> {
                val cost = data["cost"] as? Int ?: 1000  // Default cost: 1000 cash

                val svc = serverContext.requirePlayerContext(playerId).services
                val playerCash = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                if (playerCash < cost) {
                    val responseJson = JSON.encode(
                        SurvivorBuyResponse(success = false, error = notEnoughCoinsErrorId, cost = cost)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Generate a new random survivor
                val gender = if (kotlin.random.Random.nextBoolean()) "male" else "female"
                val maleNames = listOf(
                    "Tony Miller", "Peter Lawson", "Bruce Carter", "Clark Hayes", "Steve Morgan",
                    "Luke Harrison", "Rick Sanders", "Joel Thompson", "Arthur Bennett", "John Reed"
                )
                val femaleNames = listOf(
                    "Lara Croft", "Jill Harper", "Claire Bennett", "Ada Collins", "Ellie Williams",
                    "Tifa Lawson", "Aerith Sullivan", "Hermione Blake", "Hinata Kimura", "Sarah Connor"
                )
                val maleVoices = listOf("white-m", "black-m", "latino-m", "asian-m")
                val femaleVoices = listOf("white-f", "black-f", "latino-f")

                val name = (if (gender == "male") maleNames.random() else femaleNames.random()).split(" ")
                val voice = if (gender == "male") maleVoices.random() else femaleVoices.random()

                val newSurvivor = Survivor(
                    firstName = name[0],
                    lastName = name.getOrNull(1) ?: "",
                    gender = gender,
                    classId = "unassigned",
                    voice = voice,
                    title = "",
                    morale = emptyMap(),
                    injuries = emptyList(),
                    level = 1,
                    xp = 0,
                    missionId = null,
                    assignmentId = null,
                    accessories = emptyMap(),
                    maxClothingAccessories = 4
                )

                // Deduct cost
                var resourceResponse: core.model.game.data.GameResources? = null
                svc.compound.updateResource { resource ->
                    resourceResponse = resource.copy(cash = playerCash - cost)
                    resourceResponse
                }

                // Add survivor to player
                val addResult = svc.survivor.addNewSurvivor(newSurvivor)

                val responseJson = if (addResult.isSuccess) {
                    JSON.encode(
                        SurvivorBuyResponse(success = true, cost = cost, survivor = newSurvivor)
                    )
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to add survivor: ${addResult.exceptionOrNull()?.message}" }
                    JSON.encode(
                        SurvivorBuyResponse(success = false, error = "add_failed", cost = cost)
                    )
                }

                val msg = if (resourceResponse != null) {
                    buildMsg(saveId, responseJson, JSON.encode(resourceResponse))
                } else {
                    buildMsg(saveId, responseJson)
                }
                send(PIOSerializer.serialize(msg))
                
                // Send fuel update if resources changed (successful survivor buy)
                resourceResponse?.let { res ->
                    sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                }
            }

            SaveDataMethod.SURVIVOR_INJURE -> {
                val survivorId = data["id"] as? String
                val severityGroup = data["s"] as? String ?: "minor"
                val cause = data["c"] as? String ?: "unknown"
                val force = data["f"] as? Boolean ?: false
                val isCritical = data["cr"] as? Boolean ?: false

                if (survivorId == null) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val svc = serverContext.requirePlayerContext(playerId).services
                val survivor = svc.survivor.getAllSurvivors().find { it.id == survivorId }

                if (survivor == null) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // For now, simple implementation: always create an injury if force=true or 50% chance otherwise
                val shouldInjure = force || Math.random() < 0.5

                if (!shouldInjure) {
                    // No injury applied
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = true, srv = survivorId, inj = null)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Create a new injury
                val injuryTypes = listOf("bruise", "cut", "sprain", "burn")
                val injuryLocations = listOf("arm", "leg", "head", "torso")
                val injuryId = common.UUID.new()

                val (damage, morale, healTime) = when (severityGroup) {
                    "major" -> Triple(150.0, -15.0, 3600 * 24)  // 24 hours
                    "critical" -> Triple(250.0, -25.0, 3600 * 48)  // 48 hours
                    else -> Triple(50.0, -5.0, 3600 * 12)  // 12 hours (minor)
                }

                val timer = if (healTime > 0) {
                    dev.deadzone.core.model.game.data.TimerData(
                        start = System.currentTimeMillis(),
                        length = healTime.toLong(),
                        data = mapOf("id" to injuryId, "type" to "injury")
                    )
                } else null

                val injury = Injury(
                    id = injuryId,
                    type = injuryTypes.random(),
                    location = injuryLocations.random(),
                    severity = severityGroup,
                    damage = damage,
                    morale = morale,
                    timer = timer
                )

                // Add injury to survivor
                val updateResult = svc.survivor.updateSurvivor(survivorId) { currentSurvivor ->
                    currentSurvivor.copy(
                        injuries = currentSurvivor.injuries + injury
                    )
                }

                val responseJson = if (updateResult.isSuccess) {
                    JSON.encode(
                        SurvivorInjureResponse(success = true, srv = survivorId, inj = injury)
                    )
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to add injury: ${updateResult.exceptionOrNull()?.message}" }
                    JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                }

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.SURVIVOR_ENEMY_INJURE -> {
                val survivorId = data["id"] as? String
                val enemyPlayerId = data["enemyId"] as? String  // Owner of the enemy survivor
                val severityGroup = data["s"] as? String ?: "minor"
                val cause = data["c"] as? String ?: "unknown"
                val force = data["f"] as? Boolean ?: false
                val isCritical = data["cr"] as? Boolean ?: false

                if (survivorId == null) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // For PvP injuries, we might need to get survivor from different player
                val targetPlayerId = enemyPlayerId ?: playerId
                val svc = serverContext.requirePlayerContext(targetPlayerId).services
                val survivor = svc.survivor.getAllSurvivors().find { it.id == survivorId }

                if (survivor == null) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // PvP injuries have higher chance (75% vs 50%)
                val shouldInjure = force || Math.random() < 0.75

                if (!shouldInjure) {
                    val responseJson = JSON.encode(
                        SurvivorInjureResponse(success = true, srv = survivorId, inj = null)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Create injury with PvP-specific values (higher damage)
                val injuryTypes = listOf("bruise", "cut", "sprain", "burn", "fracture")
                val injuryLocations = listOf("arm", "leg", "head", "torso")
                val injuryId = common.UUID.new()

                // PvP injuries are more severe
                val (damage, morale, healTime) = when (severityGroup) {
                    "major" -> Triple(200.0, -20.0, 3600 * 36)    // 36 hours
                    "critical" -> Triple(350.0, -35.0, 3600 * 72)  // 72 hours
                    else -> Triple(75.0, -10.0, 3600 * 18)         // 18 hours (minor)
                }

                val timer = if (healTime > 0) {
                    dev.deadzone.core.model.game.data.TimerData(
                        start = System.currentTimeMillis(),
                        length = healTime.toLong(),
                        data = mapOf("id" to injuryId, "type" to "injury", "pvp" to "true")
                    )
                } else null

                val injury = Injury(
                    id = injuryId,
                    type = injuryTypes.random(),
                    location = injuryLocations.random(),
                    severity = severityGroup,
                    damage = damage,
                    morale = morale,
                    timer = timer
                )

                // Add injury to survivor
                val updateResult = svc.survivor.updateSurvivor(survivorId) { currentSurvivor ->
                    currentSurvivor.copy(
                        injuries = currentSurvivor.injuries + injury
                    )
                }

                val responseJson = if (updateResult.isSuccess) {
                    JSON.encode(
                        SurvivorInjureResponse(success = true, srv = survivorId, inj = injury)
                    )
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to add PvP injury: ${updateResult.exceptionOrNull()?.message}" }
                    JSON.encode(
                        SurvivorInjureResponse(success = false)
                    )
                }

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.SURVIVOR_HEAL_INJURY -> {
                val survivorId = data["id"] as? String
                val injuryId = data["injuryId"] as? String

                if (survivorId == null || injuryId == null) {
                    val responseJson = JSON.encode(
                        SurvivorHealResponse(success = false, error = "invalid_params")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val svc = serverContext.requirePlayerContext(playerId).services
                val survivor = svc.survivor.getAllSurvivors().find { it.id == survivorId }

                if (survivor == null) {
                    val responseJson = JSON.encode(
                        SurvivorHealResponse(success = false, error = "survivor_not_found")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val injury = survivor.injuries.find { it.id == injuryId }
                if (injury == null) {
                    val responseJson = JSON.encode(
                        SurvivorHealResponse(success = false, error = "injury_not_found")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Simple cost calculation: 50 cash per injury
                val cost = 50
                val playerCash = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                if (playerCash < cost) {
                    val responseJson = JSON.encode(
                        SurvivorHealResponse(success = false, error = notEnoughCoinsErrorId, cost = cost)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Deduct cost
                var resourceResponse: core.model.game.data.GameResources? = null
                svc.compound.updateResource { resource ->
                    resourceResponse = resource.copy(cash = playerCash - cost)
                    resourceResponse
                }

                // Remove the injury
                val updateResult = svc.survivor.updateSurvivor(survivorId) { currentSurvivor ->
                    currentSurvivor.copy(
                        injuries = currentSurvivor.injuries.filter { it.id != injuryId }
                    )
                }

                val responseJson = if (updateResult.isSuccess) {
                    JSON.encode(SurvivorHealResponse(success = true, cost = cost))
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to heal injury: ${updateResult.exceptionOrNull()?.message}" }
                    JSON.encode(SurvivorHealResponse(success = false, error = "update_failed"))
                }

                val msg = if (resourceResponse != null) {
                    buildMsg(saveId, responseJson, JSON.encode(resourceResponse))
                } else {
                    buildMsg(saveId, responseJson)
                }
                send(PIOSerializer.serialize(msg))
                
                // Send fuel update if resources changed (successful heal injury)
                resourceResponse?.let { res ->
                    sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                }
            }

            SaveDataMethod.SURVIVOR_HEAL_ALL -> {
                val survivorId = data["id"] as? String

                if (survivorId == null) {
                    val responseJson = JSON.encode(
                        SurvivorHealResponse(success = false, error = "invalid_params")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                val svc = serverContext.requirePlayerContext(playerId).services
                val survivor = svc.survivor.getAllSurvivors().find { it.id == survivorId }

                if (survivor == null) {
                    val responseJson = JSON.encode(
                        SurvivorHealResponse(success = false, error = "survivor_not_found")
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                if (survivor.injuries.isEmpty()) {
                    val responseJson = JSON.encode(
                        SurvivorHealResponse(success = true, cost = 0)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Cost: 50 cash per injury
                val cost = survivor.injuries.size * 50
                val playerCash = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                if (playerCash < cost) {
                    val responseJson = JSON.encode(
                        SurvivorHealResponse(success = false, error = notEnoughCoinsErrorId, cost = cost)
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Deduct cost
                var resourceResponse: core.model.game.data.GameResources? = null
                svc.compound.updateResource { resource ->
                    resourceResponse = resource.copy(cash = playerCash - cost)
                    resourceResponse
                }

                // Remove all injuries
                val updateResult = svc.survivor.updateSurvivor(survivorId) { currentSurvivor ->
                    currentSurvivor.copy(injuries = emptyList())
                }

                val responseJson = if (updateResult.isSuccess) {
                    JSON.encode(SurvivorHealResponse(success = true, cost = cost))
                } else {
                    Logger.error(LogConfigSocketToClient) { "Failed to heal all injuries: ${updateResult.exceptionOrNull()?.message}" }
                    JSON.encode(SurvivorHealResponse(success = false, error = "update_failed"))
                }

                val msg = if (resourceResponse != null) {
                    buildMsg(saveId, responseJson, JSON.encode(resourceResponse))
                } else {
                    buildMsg(saveId, responseJson)
                }
                send(PIOSerializer.serialize(msg))
                
                // Send fuel update if resources changed (successful heal all injuries)
                resourceResponse?.let { res ->
                    sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                }
            }

            SaveDataMethod.PLAYER_CUSTOM -> {
                val svc = serverContext.requirePlayerContext(playerId).services

                // Check if this is an attribute upgrade request (data["att"] exists)
                val attributeUpgrades = data["att"] as? Map<*, *>
                if (attributeUpgrades != null) {
                    // This is an attribute upgrade request
                    val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                    if (playerObjects == null) {
                        val responseJson = JSON.encode(PlayerCustomResponse(error = "player_not_found"))
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                        return
                    }

                    // Map attribute classes to individual attributes
                    val attributeClassMap = mapOf(
                        "FIGHTING" to listOf("combatProjectile", "combatMelee"),
                        "SCAVENGING" to listOf("scavenge"),
                        "ENGINEERING" to listOf("combatImprovised", "trapDisarming"),
                        "MEDIC" to listOf("healing"),
                        "RECON" to listOf("movement", "trapSpotting")
                    )

                    // Calculate total points spent
                    var totalPointsSpent = 0
                    for ((className, pointsObj) in attributeUpgrades) {
                        val points = (pointsObj as? Number)?.toInt() ?: 0
                        totalPointsSpent += points
                    }

                    // Check if player has enough levelPts
                    if (totalPointsSpent > playerObjects.levelPts.toInt()) {
                        val responseJson = JSON.encode(
                            PlayerCustomResponse(error = "insufficient_points")
                        )
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                        return
                    }

                    // Apply attribute upgrades
                    val currentAttributes = playerObjects.playerAttributes
                    val updatedAttributes = currentAttributes.copy(
                        health = currentAttributes.health +
                                (((attributeUpgrades["FIGHTING"] as? Number)?.toInt() ?: 0) * 10.0) +
                                (((attributeUpgrades["SCAVENGING"] as? Number)?.toInt() ?: 0) * 10.0) +
                                (((attributeUpgrades["ENGINEERING"] as? Number)?.toInt() ?: 0) * 10.0) +
                                (((attributeUpgrades["MEDIC"] as? Number)?.toInt() ?: 0) * 10.0) +
                                (((attributeUpgrades["RECON"] as? Number)?.toInt() ?: 0) * 10.0),
                        combatProjectile = currentAttributes.combatProjectile +
                                (((attributeUpgrades["FIGHTING"] as? Number)?.toInt() ?: 0) * 0.1),
                        combatMelee = currentAttributes.combatMelee +
                                (((attributeUpgrades["FIGHTING"] as? Number)?.toInt() ?: 0) * 0.1),
                        scavenge = currentAttributes.scavenge +
                                (((attributeUpgrades["SCAVENGING"] as? Number)?.toInt() ?: 0) * 0.1),
                        combatImprovised = currentAttributes.combatImprovised +
                                (((attributeUpgrades["ENGINEERING"] as? Number)?.toInt() ?: 0) * 0.1),
                        trapDisarming = currentAttributes.trapDisarming +
                                (((attributeUpgrades["ENGINEERING"] as? Number)?.toInt() ?: 0) * 0.1),
                        healing = currentAttributes.healing +
                                (((attributeUpgrades["MEDIC"] as? Number)?.toInt() ?: 0) * 0.1),
                        movement = currentAttributes.movement +
                                (((attributeUpgrades["RECON"] as? Number)?.toInt() ?: 0) * 0.1),
                        trapSpotting = currentAttributes.trapSpotting +
                                (((attributeUpgrades["RECON"] as? Number)?.toInt() ?: 0) * 0.1)
                    )

                    // Deduct levelPts and save
                    val updatedPlayerObjects = playerObjects.copy(
                        playerAttributes = updatedAttributes,
                        levelPts = (playerObjects.levelPts.toInt() - totalPointsSpent).toUInt()
                    )

                    val updateResult = runCatching {
                        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                    }

                    if (updateResult.isFailure) {
                        Logger.error(LogConfigSocketError) {
                            "Failed to update player attributes for playerId=$playerId: ${updateResult.exceptionOrNull()?.message}"
                        }
                        val responseJson = JSON.encode(PlayerCustomResponse(error = "update_failed"))
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                        return
                    }

                    // Return updated attributes and remaining levelPts as Map
                    val attributesMap = mapOf(
                        "health" to updatedAttributes.health,
                        "combatProjectile" to updatedAttributes.combatProjectile,
                        "combatMelee" to updatedAttributes.combatMelee,
                        "combatImprovised" to updatedAttributes.combatImprovised,
                        "movement" to updatedAttributes.movement,
                        "scavenge" to updatedAttributes.scavenge,
                        "healing" to updatedAttributes.healing,
                        "trapSpotting" to updatedAttributes.trapSpotting,
                        "trapDisarming" to updatedAttributes.trapDisarming,
                        "injuryChance" to updatedAttributes.injuryChance
                    )

                    val responseJson = JSON.encode(
                        PlayerCustomResponse(
                            attributes = attributesMap,
                            levelPts = updatedPlayerObjects.levelPts.toInt()
                        )
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Original PLAYER_CUSTOM logic for initial customization
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

                // svc already declared at the beginning of PLAYER_CUSTOM handler

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
                Logger.info(LogConfigSocketToClient) { "'RESET_LEADER' message received" }

                val svc = serverContext.requirePlayerContext(playerId).services
                val leader = svc.survivor.getSurvivorLeader()

                // Minimum level required to reset (typically level 10+)
                val minLevel = 10
                if (leader.level < minLevel) {
                    val responseJson = JSON.encode(
                        mapOf(
                            "error" to "55", // Not enough coins / invalid action
                            "success" to false
                        )
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Calculate total level points available (1 point per level after level 1)
                val totalLevelPts = leader.level - 1

                // Reset attributes to starter values
                val resetAttributes = Attributes.starter()

                // Load player objects and update attributes + levelPts
                val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                if (playerObjects == null) {
                    val responseJson = JSON.encode(
                        mapOf(
                            "error" to "Database error",
                            "success" to false
                        )
                    )
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }

                // Update player objects with reset attributes and new levelPts
                val updatedPlayerObjects = playerObjects.copy(
                    playerAttributes = resetAttributes,
                    levelPts = totalLevelPts.toUInt()
                )

                serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

                // Set a cooldown for reset (24 hours = 86400000 milliseconds)
                val cooldownBytes = byteArrayOf(0) // Placeholder for cooldown encoding

                // Prepare response with reset attributes
                val attributesMap: Map<String, Double> = mapOf(
                    "health" to resetAttributes.health,
                    "combatProjectile" to resetAttributes.combatProjectile,
                    "combatMelee" to resetAttributes.combatMelee,
                    "combatImprovised" to resetAttributes.combatImprovised,
                    "movement" to resetAttributes.movement,
                    "scavenge" to resetAttributes.scavenge,
                    "healing" to resetAttributes.healing,
                    "trapSpotting" to resetAttributes.trapSpotting,
                    "trapDisarming" to resetAttributes.trapDisarming,
                    "injuryChance" to resetAttributes.injuryChance
                )

                val responseJson = JSON.encode(
                    mapOf<String, Any>(
                        "success" to true,
                        "attributes" to attributesMap,
                        "levelPts" to totalLevelPts
                    )
                )

                Logger.info(LogConfigSocketToClient) { "Leader attributes reset successfully for playerId=$playerId, levelPts=$totalLevelPts" }
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }
        }
    }
}