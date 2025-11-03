package server.handler.save.mission

import server.broadcast.BroadcastService
import context.requirePlayerContext
import core.data.GameDefinition
import core.items.model.Item
import core.items.model.combineItems
import core.items.model.compactString
import core.items.model.stackOwnItems
import core.mission.LootService
import core.mission.model.LootContent
import core.mission.model.LootParameter
import core.model.game.data.GameResources
import core.model.game.data.MissionStats
import core.model.game.data.ZombieData
import core.model.game.data.toFlatList
import dev.deadzone.core.model.game.data.TimerData
import dev.deadzone.core.model.game.data.reduceBy
import dev.deadzone.core.model.game.data.reduceByHalf
import dev.deadzone.core.model.game.data.secondsLeftToEnd
import dev.deadzone.socket.handler.save.SaveHandlerContext
import dev.deadzone.socket.tasks.impl.MissionReturnTask
import dev.deadzone.socket.tasks.impl.MissionReturnStopParameter
import io.ktor.util.date.*
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.mission.response.*
import server.handler.save.mission.response.loadSceneXML
import server.messaging.NetworkMessage
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import server.tasks.TaskCategory
import utils.JSON
import utils.LogConfigSocketToClient
import utils.Logger
import utils.SpeedUpCostCalculator
import utils.UUID
import kotlin.math.pow
import kotlin.random.Random
import kotlin.time.Duration
import kotlin.time.Duration.Companion.hours
import kotlin.time.Duration.Companion.seconds
import kotlin.time.DurationUnit

class MissionSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.MISSION_SAVES

    private val missionStats: MutableMap<String, MissionStats> = mutableMapOf()

    private val activeMissions = mutableMapOf<String, Pair<String, List<LootContent>>>()

    private val missionReturnTasks = mutableMapOf<String, Triple<String, Long, Int>>()

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId
        when (type) {
            SaveDataMethod.MISSION_START -> {
                val assignmentId = data["assignmentId"] as? String

                val svc = serverContext.requirePlayerContext(playerId).services
                val leader = svc.survivor.getSurvivorLeader()

                val isCompoundZombieAttack = data["compound"]?.equals(true)
                val sceneXML: String

                val arenaSession = if (assignmentId != null) {
                    serverContext.db.getActiveArenaSession(assignmentId)
                } else {
                    null
                }

                if (arenaSession != null) {
                    val arenaDefinition = GameDefinition.arenasById[arenaSession.arenaName]
                    if (arenaDefinition == null) {
                        Logger.error(LogConfigSocketToClient) { "Arena definition '${arenaSession.arenaName}' not found" }
                        return
                    }

                    val stageDef = arenaDefinition.stages.getOrNull(arenaSession.currentStageIndex)
                        ?: arenaDefinition.stages.first()
                    val mapName = stageDef.maps.randomOrNull() ?: ""

                    if (mapName.isEmpty()) {
                        Logger.error(LogConfigSocketToClient) { "No map configured for arena '${arenaSession.arenaName}' stage ${arenaSession.currentStageIndex}" }
                        return
                    }

                    Logger.info(LogConfigSocketToClient) { "Loading arena map: $mapName for assignmentId=$assignmentId" }
                    try {
                        sceneXML = loadSceneXML(mapName)
                    } catch (e: Exception) {
                        Logger.error(LogConfigSocketToClient) { "Failed to load arena map '$mapName': ${e.message}" }
                        return
                    }
                } else {
                    val areaType = if (isCompoundZombieAttack == true) {
                        "compound"
                    } else {
                        val providedAreaType = data["areaType"] as? String
                        if (providedAreaType == null) {
                            Logger.warn(LogConfigSocketToClient) { "areaType not provided in MISSION_START data, using default 'residential'" }
                        }
                        providedAreaType ?: "residential"
                    }
                    Logger.info(LogConfigSocketToClient) { "Going to scene with areaType=$areaType" }

                    val loadedScene = resolveAndLoadScene(areaType)
                    if (loadedScene == null) {
                        Logger.error(LogConfigSocketToClient) { "That area=$areaType isn't working yet, typically because the map file is lost" }
                        return
                    }
                    sceneXML = loadedScene
                }
                val config = GameDefinition.config
                val lootParameter = LootParameter(
                    areaLevel = (data["areaLevel"] as? Int ?: 0),
                    playerLevel = leader.level,
                    itemWeightOverrides = mapOf(),
                    specificItemBoost = mapOf(
                        "fuel-bottle" to config.lootBoostFuelItems,
                        "fuel-container" to config.lootBoostFuelItems,
                        "fuel" to config.lootBoostFuelItems,
                        "fuel-cans" to config.lootBoostFuelItems,
                    ),
                    itemTypeBoost = mapOf(
                        "junk" to config.lootBoostJunkItems
                    ),
                    itemQualityBoost = mapOf(
                        "blue" to config.lootBoostBlueQuality
                    ),
                    baseWeight = 1.0,
                    fuelLimit = 50
                )
                val lootService = LootService(sceneXML, lootParameter)
                val (sceneXMLWithLoot, insertedLoots) = lootService.insertLoots()

                val zombies = listOf(
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                    ZombieData.dogStandard(Random.nextInt()),
                    ZombieData.fatWalkerStrongAttack(Random.nextInt()),
                ).flatMap { it.toFlatList() }

                val timeSeconds = if (isCompoundZombieAttack == true) GameDefinition.config.compoundAttackTime else 240

                val missionId = connection.playerId
                activeMissions[connection.playerId] = missionId to insertedLoots

                val responseJson = JSON.encode(
                    MissionStartResponse(
                        id = missionId,
                        time = timeSeconds,
                        assignmentType = if (arenaSession != null) "Arena" else "None",
                        areaClass = (data["areaClass"] as String?) ?: "", 
                        automated = false,
                        sceneXML = sceneXMLWithLoot,
                        z = zombies,
                        allianceAttackerEnlisting = false,
                        allianceAttackerLockout = false,
                        allianceAttackerAllianceId = null,
                        allianceAttackerAllianceTag = null,
                        allianceMatch = false,
                        allianceRound = 0,
                        allianceRoundActive = false,
                        allianceError = false,
                        allianceAttackerWinPoints = 0
                    )
                )

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)), logFull = false)
            }

            SaveDataMethod.MISSION_START_FLAG -> {
                Logger.info { "<----- Mission start flag received ----->" }
            }

            SaveDataMethod.MISSION_INTERACTION_FLAG -> {
                Logger.info { "<----- First interaction received ----->" }
            }

            SaveDataMethod.MISSION_END -> {
                val svc = serverContext.requirePlayerContext(playerId).services
                val leader = svc.survivor.getSurvivorLeader()

                val playerStats = missionStats[connection.playerId] ?: MissionStats()
                val earnedXp = calculateMissionXp(playerStats.killData)

                val (missionId, insertedLoots) =
                    requireNotNull(activeMissions[connection.playerId]) { "Mission ID for playerId=$playerId was somehow null in MISSION_END request." }

                val rawLootedItems = summarizeLoots(data, insertedLoots)
                val (combinedLootedItems, obtainedResources) = buildInventoryAndResource(rawLootedItems)

                val newXp = leader.xp + earnedXp
                val (newLevel, newLevelPts) = calculateNewLevelAndPoints(leader.level, leader.xp, newXp)

                svc.survivor.updateSurvivor(leader.id) { currentLeader ->
                    currentLeader.copy(xp = newXp, level = newLevel)
                }

                if (newLevelPts > 0) {
                    try {
                        BroadcastService.broadcastUserLevel(connection.playerId, newLevel)
                    } catch (e: Exception) {
                        Logger.warn("Failed to broadcast user level: ${e.message}")
                    }
                }

                try {
                    combinedLootedItems.forEach { item ->
                        val quality = item.quality?.toString() ?: ""
                        if (quality.equals("legendary", ignoreCase = true) || quality.equals("epic", ignoreCase = true)) {
                            BroadcastService.broadcastItemFound(connection.playerId, item.type, quality)
                        }
                    }
                } catch (e: Exception) {
                    Logger.warn("Failed to broadcast items found: ${e.message}")
                }

                svc.inventory.updateInventory { items ->
                    items.combineItems(
                        combinedLootedItems.filter { !GameDefinition.isResourceItem(it.type) },
                        GameDefinition
                    )
                }

                svc.compound.updateResource { currentRes ->
                    val storageLimit = GameDefinition.config.storageCapacityDefault
                    val cappedResources = GameResources(
                        wood = minOf(currentRes.wood + obtainedResources.wood, storageLimit),
                        metal = minOf(currentRes.metal + obtainedResources.metal, storageLimit),
                        cloth = minOf(currentRes.cloth + obtainedResources.cloth, storageLimit),
                        water = minOf(currentRes.water + obtainedResources.water, storageLimit),
                        food = minOf(currentRes.food + obtainedResources.food, storageLimit),
                        ammunition = minOf(currentRes.ammunition + obtainedResources.ammunition, storageLimit),
                        cash = currentRes.cash + obtainedResources.cash 
                    )
                    cappedResources
                }

                val returnTime = GameDefinition.config.baseReturnTime.seconds

                val responseJson = JSON.encode(
                    MissionEndResponse(
                        automated = false,
                        xpEarned = earnedXp,
                        xp = XpBreakdown(total = earnedXp),
                        returnTimer = TimerData.runForDuration(
                            duration = returnTime,
                            data = mapOf("return" to returnTime.toInt(DurationUnit.SECONDS))
                        ),
                        lockTimer = null,
                        loot = combinedLootedItems,

                        itmCounters = emptyMap(),
                        injuries = null,
                        survivors = emptyList(),
                        player = PlayerSurvivor(
                            xp = newXp,
                            level = newLevel
                        ),
                        levelPts = newLevelPts,
                        cooldown = null
                    )
                )

                val resourceResponseJson = JSON.encode(svc.compound.getResources())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))

                missionReturnTasks[missionId] = Triple(
                    connection.playerId,
                    getTimeMillis(),
                    returnTime.inWholeSeconds.toInt()
                )

                serverContext.taskDispatcher.runTaskFor(
                    connection = connection,
                    taskToRun = MissionReturnTask(
                        taskInputBlock = {
                            this.missionId = missionId
                            this.returnTime = returnTime
                        },
                        stopInputBlock = {
                            this.missionId = missionId
                        }
                    )
                )

                missionStats.remove(connection.playerId)
                activeMissions.remove(connection.playerId)
            }

            SaveDataMethod.MISSION_ZOMBIES -> {
                

                val zombies = listOf(
                    ZombieData.strongRunner(Random.nextInt()),
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                ).flatMap { it.toFlatList() }

                val responseJson = JSON.encode(
                    GetZombieResponse(
                        max = false,
                        z = zombies
                    )
                )

                Logger.info(LogConfigSocketToClient) { "'mis_zombies' message (spawn zombie) request received" }

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.MISSION_INJURY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_INJURY' message [not implemented]" }
            }

            SaveDataMethod.MISSION_SPEED_UP -> {
                val option = data["option"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'MISSION_SPEED_UP' message with option=$option" }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val playerFuel = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                val missionEntry = missionReturnTasks.entries.find { it.value.first == connection.playerId }

                if (missionEntry == null) {
                    Logger.warn(LogConfigSocketToClient) { "Mission return task not found for playerId=${connection.playerId}" }
                    val response = MissionSpeedUpResponse(error = "Task not found", success = false, cost = 0)
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return@with
                }

                val (missionId, taskInfo) = missionEntry
                val (_, startTime, durationSeconds) = taskInfo

                val elapsedTimeMs = getTimeMillis() - startTime
                val elapsedSeconds = (elapsedTimeMs / 1000).toInt()
                val secondsRemaining = maxOf(0, durationSeconds - elapsedSeconds)

                val response: MissionSpeedUpResponse
                var resourceResponse: GameResources? = null

                val cost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)

                if (playerFuel < cost) {
                    response = MissionSpeedUpResponse(error = notEnoughCoinsErrorId, success = false, cost = cost)
                } else {
                    val newRemainingSeconds = when (option) {
                        "SpeedUpOneHour" -> maxOf(0, secondsRemaining - 3600)
                        "SpeedUpTwoHour" -> maxOf(0, secondsRemaining - 7200)
                        "SpeedUpHalf" -> secondsRemaining / 2
                        "SpeedUpComplete" -> 0
                        "SpeedUpFree" -> {
                            if (secondsRemaining <= 300) {
                                0
                            } else {
                                Logger.warn { "Received unexpected MissionSpeedUp FREE option from playerId=${connection.playerId} (speed up requested when return time more than 5 minutes)" }
                                -1 
                            }
                        }
                        else -> {
                            Logger.warn { "Received unknown MissionSpeedUp option: $option from playerId=${connection.playerId}" }
                            -1 
                        }
                    }

                    if (newRemainingSeconds >= 0) {
                        svc.compound.updateResource { resource ->
                            resourceResponse = resource.copy(cash = playerFuel - cost)
                            resourceResponse
                        }

                        serverContext.taskDispatcher.stopTaskFor<MissionReturnStopParameter>(
                            connection = connection,
                            category = TaskCategory.Mission.Return,
                            stopInputBlock = {
                                this.missionId = missionId
                            }
                        )

                        if (newRemainingSeconds == 0) {
                            
                            missionReturnTasks.remove(missionId)

                            connection.sendMessage(NetworkMessage.MISSION_RETURN_COMPLETE, missionId)
                        } else {
                            
                            val newStartTime = getTimeMillis()
                            missionReturnTasks[missionId] = Triple(connection.playerId, newStartTime, newRemainingSeconds)

                            serverContext.taskDispatcher.runTaskFor(
                                connection = connection,
                                taskToRun = MissionReturnTask(
                                    taskInputBlock = {
                                        this.missionId = missionId
                                        this.returnTime = newRemainingSeconds.seconds
                                    },
                                    stopInputBlock = {
                                        this.missionId = missionId
                                    }
                                )
                            )
                        }

                        response = MissionSpeedUpResponse(error = "", success = true, cost = cost)
                    } else {
                        response = MissionSpeedUpResponse(error = "", success = false, cost = 0)
                    }
                }

                val responseJson = JSON.encode(response)
                val resourceResponseJson = JSON.encode(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
            }

            SaveDataMethod.MISSION_SCOUTED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_SCOUTED' message [not implemented]" }
            }

            SaveDataMethod.MISSION_ITEM_USE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_ITEM_USE' message [not implemented]" }
            }

            SaveDataMethod.MISSION_TRIGGER -> {
                
                
                val triggerId = data["id"] as? String ?: run {
                    Logger.warn(LogConfigSocketToClient) { "MISSION_TRIGGER: Missing trigger 'id' field" }
                    val responseJson = JSON.encode(mapOf("success" to false))
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    return
                }
                
                Logger.info(LogConfigSocketToClient) { "MISSION_TRIGGER: Trigger '$triggerId' activated" }
                
                val assignmentId = data["assignmentId"] as? String
                
                if (assignmentId != null) {
                    
                    val arenaSession = serverContext.db.getActiveArenaSession(assignmentId)
                    
                    if (arenaSession == null) {
                        Logger.warn(LogConfigSocketToClient) { 
                            "MISSION_TRIGGER: Arena session not found for assignmentId=$assignmentId" 
                        }
                        val responseJson = JSON.encode(mapOf("success" to false))
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                        return
                    }
                    
                    val arenaDefinition = GameDefinition.arenasById[arenaSession.arenaName]
                    if (arenaDefinition == null) {
                        Logger.error(LogConfigSocketToClient) { 
                            "MISSION_TRIGGER: Arena definition '${arenaSession.arenaName}' not found" 
                        }
                        val responseJson = JSON.encode(mapOf("success" to false))
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                        return
                    }
                    
                    val stageDef = arenaDefinition.stages.getOrNull(arenaSession.currentStageIndex)
                    if (stageDef == null) {
                        Logger.warn(LogConfigSocketToClient) { 
                            "MISSION_TRIGGER: Invalid stage index ${arenaSession.currentStageIndex} for arena '${arenaSession.arenaName}'" 
                        }
                        val responseJson = JSON.encode(mapOf("success" to false))
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                        return
                    }
                    
                    val triggerPoints = stageDef.triggerPoints
                    
                    if (triggerPoints <= 0) {
                        Logger.warn(LogConfigSocketToClient) { 
                            "MISSION_TRIGGER: No points configured for trigger in stage ${arenaSession.currentStageIndex}" 
                        }
                        val responseJson = JSON.encode(mapOf("success" to false))
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                        return
                    }
                    
                    val updatedStages = arenaSession.stages.mapIndexed { index, stage ->
                        if (index == arenaSession.currentStageIndex) {
                            stage.copy(objectivePoints = stage.objectivePoints + triggerPoints)
                        } else {
                            stage
                        }
                    }
                    
                    val newTotalPoints = updatedStages.sumOf { it.survivorPoints + it.objectivePoints }
                    
                    val updatedSession = arenaSession.copy(
                        stages = updatedStages,
                        totalPoints = newTotalPoints,
                        lastUpdatedAt = System.currentTimeMillis()
                    )
                    
                    try {
                        serverContext.db.saveActiveArenaSession(updatedSession)
                        Logger.info(LogConfigSocketToClient) { 
                            "MISSION_TRIGGER: Added $triggerPoints objective points to arena session ${arenaSession.id}, " +
                            "new total: $newTotalPoints"
                        }
                        val responseJson = JSON.encode(mapOf("success" to true))
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    } catch (e: Exception) {
                        Logger.error(LogConfigSocketToClient) { 
                            "MISSION_TRIGGER: Failed to update arena session: ${e.message}" 
                        }
                        val responseJson = JSON.encode(mapOf("success" to false))
                        send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    }
                } else {
                    
                    Logger.info(LogConfigSocketToClient) { 
                        "MISSION_TRIGGER: Trigger '$triggerId' activated in non-arena mission" 
                    }
                    val responseJson = JSON.encode(mapOf("success" to true))
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                }
            }

            SaveDataMethod.MISSION_ELITE_SPAWNED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_ELITE_SPAWNED' message [not implemented]" }
            }

            SaveDataMethod.MISSION_ELITE_KILLED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_ELITE_KILLED' message [not implemented]" }
            }

            SaveDataMethod.STAT_DATA -> {
                val playerStats = parseMissionStats(data["stats"])
                Logger.debug(logFull = true) { "STAT_DATA parsed: $playerStats" }
                missionStats[connection.playerId] = playerStats
            }

            SaveDataMethod.STAT -> {
                val playerStats = parseMissionStats(data["stats"])
                Logger.debug(logFull = true) { "STAT parsed: $missionStats" }
                missionStats[connection.playerId] = playerStats
            }
        }
    }

    private fun parseMissionStats(raw: Any?): MissionStats {
        val m = (raw as? Map<*, *>) ?: emptyMap<Any?, Any?>()
        fun asInt(v: Any?): Int = when (v) {
            is Int -> v
            is Long -> v.toInt()
            is Double -> v.toInt()
            is Float -> v.toInt()
            is Number -> v.toInt()
            is String -> v.toIntOrNull() ?: 0
            else -> 0
        }

        fun asDouble(v: Any?): Double = when (v) {
            is Double -> v
            is Float -> v.toDouble()
            is Int -> v.toDouble()
            is Long -> v.toDouble()
            is Number -> v.toDouble()
            is String -> v.toDoubleOrNull() ?: 0.0
            else -> 0.0
        }

        val knownKeys = setOf(
            "zombieSpawned", "levelUps", "damageOutput", "damageTaken", "containersSearched",
            "survivorKills", "survivorsDowned", "survivorExplosiveKills",
            "humanKills", "humanExplosiveKills",
            "zombieKills", "zombieExplosiveKills",
            "hpHealed", "explosivesPlaced", "grenadesThrown", "grenadesSmokeThrown",
            "allianceFlagCaptured", "buildingsDestroyed", "buildingsLost", "buildingsExplosiveDestroyed",
            "trapsTriggered", "trapDisarmTriggered",
            "cashFound", "woodFound", "metalFound", "clothFound", "foodFound", "waterFound",
            "ammunitionFound", "ammunitionUsed",
            "weaponsFound", "gearFound", "junkFound", "medicalFound", "craftingFound",
            "researchFound", "researchNoteFound", "clothingFound", "cratesFound", "schematicsFound",
            "effectFound", "rareWeaponFound", "rareGearFound", "uniqueWeaponFound", "uniqueGearFound",
            "greyWeaponFound", "greyGearFound", "whiteWeaponFound", "whiteGearFound",
            "greenWeaponFound", "greenGearFound", "blueWeaponFound", "blueGearFound",
            "purpleWeaponFound", "purpleGearFound", "premiumWeaponFound", "premiumGearFound"
        )

        val killData = buildMap {
            for ((kAny, v) in m) {
                val k = kAny?.toString() ?: continue
                if (k.endsWith("-kills") || k.endsWith("-explosive-kills")) {
                    put(k, asInt(v))
                }
            }
        }

        val customData = buildMap {
            for ((kAny, v) in m) {
                val k = kAny?.toString() ?: continue
                if (k !in knownKeys && !k.endsWith("-kills") && !k.endsWith("-explosive-kills")) {
                    val iv = asInt(v)
                    if (iv != 0) put(k, iv)
                }
            }
        }

        return MissionStats(
            zombieSpawned = asInt(m["zombieSpawned"]),
            levelUps = asInt(m["levelUps"]),
            damageOutput = asDouble(m["damageOutput"]),
            damageTaken = asDouble(m["damageTaken"]),
            containersSearched = asInt(m["containersSearched"]),
            survivorKills = asInt(m["survivorKills"]),
            survivorsDowned = asInt(m["survivorsDowned"]),
            survivorExplosiveKills = asInt(m["survivorExplosiveKills"]),
            humanKills = asInt(m["humanKills"]),
            humanExplosiveKills = asInt(m["humanExplosiveKills"]),
            zombieKills = asInt(m["zombieKills"]),
            zombieExplosiveKills = asInt(m["zombieExplosiveKills"]),
            hpHealed = asInt(m["hpHealed"]),
            explosivesPlaced = asInt(m["explosivesPlaced"]),
            grenadesThrown = asInt(m["grenadesThrown"]),
            grenadesSmokeThrown = asInt(m["grenadesSmokeThrown"]),
            allianceFlagCaptured = asInt(m["allianceFlagCaptured"]),
            buildingsDestroyed = asInt(m["buildingsDestroyed"]),
            buildingsLost = asInt(m["buildingsLost"]),
            buildingsExplosiveDestroyed = asInt(m["buildingsExplosiveDestroyed"]),
            trapsTriggered = asInt(m["trapsTriggered"]),
            trapDisarmTriggered = asInt(m["trapDisarmTriggered"]),
            cashFound = asInt(m["cashFound"]),
            woodFound = asInt(m["woodFound"]),
            metalFound = asInt(m["metalFound"]),
            clothFound = asInt(m["clothFound"]),
            foodFound = asInt(m["foodFound"]),
            waterFound = asInt(m["waterFound"]),
            ammunitionFound = asInt(m["ammunitionFound"]),
            ammunitionUsed = asInt(m["ammunitionUsed"]),
            weaponsFound = asInt(m["weaponsFound"]),
            gearFound = asInt(m["gearFound"]),
            junkFound = asInt(m["junkFound"]),
            medicalFound = asInt(m["medicalFound"]),
            craftingFound = asInt(m["craftingFound"]),
            researchFound = asInt(m["researchFound"]),
            researchNoteFound = asInt(m["researchNoteFound"]),
            clothingFound = asInt(m["clothingFound"]),
            cratesFound = asInt(m["cratesFound"]),
            schematicsFound = asInt(m["schematicsFound"]),
            effectFound = asInt(m["effectFound"]),
            rareWeaponFound = asInt(m["rareWeaponFound"]),
            rareGearFound = asInt(m["rareGearFound"]),
            uniqueWeaponFound = asInt(m["uniqueWeaponFound"]),
            uniqueGearFound = asInt(m["uniqueGearFound"]),
            greyWeaponFound = asInt(m["greyWeaponFound"]),
            greyGearFound = asInt(m["greyGearFound"]),
            whiteWeaponFound = asInt(m["whiteWeaponFound"]),
            whiteGearFound = asInt(m["whiteGearFound"]),
            greenWeaponFound = asInt(m["greenWeaponFound"]),
            greenGearFound = asInt(m["greenGearFound"]),
            blueWeaponFound = asInt(m["blueWeaponFound"]),
            blueGearFound = asInt(m["blueGearFound"]),
            purpleWeaponFound = asInt(m["purpleWeaponFound"]),
            purpleGearFound = asInt(m["purpleGearFound"]),
            premiumWeaponFound = asInt(m["premiumWeaponFound"]),
            premiumGearFound = asInt(m["premiumGearFound"]),
            killData = killData,
            customData = customData
        )
    }

    @Suppress("UNCHECKED_CAST")
    private fun summarizeLoots(data: Map<String, Any?>, serverInsertedLoots: List<LootContent>): List<Item> {
        val lootedIds: List<String> =
            requireNotNull(data["loot"] as? List<String>) { "Error: 'loot' structure in data is not as expected, data: $data" }
        val items = mutableSetOf<Item>()

        lootedIds.forEach { lootId ->
            val loot = serverInsertedLoots.find { it.lootId == lootId }
            if (loot != null) {
                items.add(Item(id = UUID.new(), type = loot.itemIdInXML, qty = loot.quantity.toUInt(), new = true))
            } else {
                Logger.warn { "Unexpected scenario: player reportedly loot:$lootId but it doesn't exist in serverInsertedLoots." }
            }
        }

        return items.toList()
    }

    private fun buildInventoryAndResource(items: List<Item>): Pair<List<Item>, GameResources> {
        var totalRes = GameResources()

        for (item in items) {
            if (GameDefinition.isResourceItem(item.type)) {
                val resAmount = GameDefinition.getResourceAmount(item.type)
                if (resAmount != null) {
                    totalRes += resAmount
                } else {
                    Logger.warn { "Unexpected scenario: item=${item.compactString()} was classified as resource item but getResourceAmount returns null" }
                }
            }
        }

        return items.stackOwnItems(GameDefinition) to totalRes
    }

    private fun calculateNewLevelAndPoints(currentLevel: Int, currentXp: Int, newXp: Int): Pair<Int, Int> {
        var level = currentLevel
        var levelPts = 0
        var xp = currentXp

        while (xp < newXp) {
            val xpForNextLevel = calculateXpForNextLevel(level)
            if (newXp >= xp + xpForNextLevel) {
                level++
                levelPts++
                xp += xpForNextLevel
            } else {
                break
            }
        }

        return Pair(level, levelPts)
    }

    private fun calculateXpForNextLevel(currentLevel: Int): Int {
        return (100 * (currentLevel.toDouble().pow(1.5))).toInt()
    }

    private fun calculateMissionXp(killData: Map<String, Int>): Int {
        val config = GameDefinition.config
        var totalXp = config.missionBaseXp
        totalXp += (killData["zombie"] ?: 0) * config.missionZombieKillXp
        totalXp += (killData["runner"] ?: 0) * config.missionRunnerKillXp
        totalXp += (killData["fatty"] ?: 0) * config.missionFattyKillXp
        totalXp += (killData["boss"] ?: 0) * config.missionBossKillXp
        return totalXp.coerceAtMost(config.missionMaxXp)
    }
}
