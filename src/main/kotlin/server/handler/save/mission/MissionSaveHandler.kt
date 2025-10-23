package server.handler.save.mission

import server.broadcast.BroadcastService
import context.GlobalContext
import context.requirePlayerContext
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
import dev.deadzone.socket.handler.save.SaveHandlerContext
import dev.deadzone.socket.handler.save.mission.response.MissionSpeedUpResponse
import dev.deadzone.socket.tasks.impl.MissionReturnTask
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.mission.response.*
import server.messaging.NetworkMessage
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import utils.LogConfigSocketToClient
import utils.Logger
import utils.UUID
import kotlin.math.pow
import kotlin.random.Random
import kotlin.time.Duration.Companion.seconds
import kotlin.time.DurationUnit

class MissionSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.MISSION_SAVES

    // save stats of playerId: MissionStats
    // use this to know loots, EXP, kills, etc. after mission ended.
    private val missionStats: MutableMap<String, MissionStats> = mutableMapOf()

    // when player start a mission, generate missionId
    // this map from playerId to (missionId, insertedLoots)
    private val activeMissions = mutableMapOf<String, Pair<String, List<LootContent>>>()

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId
        when (type) {
            SaveDataMethod.MISSION_START -> {
                // IMPORTANT NOTE: the scene that involves human model is not working now (e.g., raid island human)
                // the same error is for survivor class if you fill SurvivorAppearance non-null value
                // The error was 'cyclic object' thing.
                val isCompoundZombieAttack = data["compound"]?.equals(true)
                val areaType = if (isCompoundZombieAttack == true) "compound" else data["areaType"] as String
                Logger.info(LogConfigSocketToClient) { "Going to scene with areaType=$areaType" }

                val svc = serverContext.requirePlayerContext(playerId).services
                val leader = svc.survivor.getSurvivorLeader()

                val sceneXML = resolveAndLoadScene(areaType)
                if (sceneXML == null) {
                    Logger.error(LogConfigSocketToClient) { "That area=$areaType isn't working yet, typically because the map file is lost" }
                    return
                }
                val lootParameter = LootParameter(
                    areaLevel = (data["areaLevel"] as? Int ?: 0),
                    playerLevel = leader.level,
                    itemWeightOverrides = mapOf(),
                    specificItemBoost = mapOf(
                        "fuel-bottle" to 3.0,    // +300% find fuel chance (of the base chance)
                        "fuel-container" to 3.0,
                        "fuel" to 3.0,
                        "fuel-cans" to 3.0,
                    ),
                    itemTypeBoost = mapOf(
                        "junk" to 0.8 // +80% junk find chance
                    ),
                    itemQualityBoost = mapOf(
                        "blue" to 0.5 // +50% blue quality find chance
                    ),
                    baseWeight = 1.0,
                    fuelLimit = 50
                )
                val lootService = LootService(GlobalContext.gameDefinitions, sceneXML, lootParameter)
                val (sceneXMLWithLoot, insertedLoots) = lootService.insertLoots()

                val zombies = listOf(
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                    ZombieData.dogStandard(Random.nextInt()),
                    ZombieData.fatWalkerStrongAttack(Random.nextInt()),
                ).flatMap { it.toFlatList() }

                val timeSeconds = if (isCompoundZombieAttack == true) 30 else 240

                // temporarily use player's ID as missionId itself
                // this enables deterministic ID therefore can avoid memory leak
                // later, should save the missionId as task to DB in MISSION_END
                val missionId = connection.playerId
                activeMissions[connection.playerId] = missionId to insertedLoots

                val responseJson = GlobalContext.json.encodeToString(
                    MissionStartResponse(
                        id = missionId,
                        time = timeSeconds,
                        assignmentType = "None", // 'None' because not a raid or arena. see AssignmentType
                        areaClass = (data["areaClass"] as String?) ?: "", // supposedly depend on the area
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

                // Calculate new XP and level
                val newXp = leader.xp + earnedXp
                val (newLevel, newLevelPts) = calculateNewLevelAndPoints(leader.level, leader.xp, newXp)

                // Update the leader's XP and level
                svc.survivor.updateSurvivor(leader.id) { currentLeader ->
                    currentLeader.copy(xp = newXp, level = newLevel)
                }

                // Broadcast level up if player leveled up
                if (newLevelPts > 0) {
                    try {
                        BroadcastService.broadcastUserLevel(connection.playerId, newLevel)
                    } catch (e: Exception) {
                        Logger.warn("Failed to broadcast user level: ${e.message}")
                    }
                }

                // Broadcast rare items found
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

                // Update player's inventory
                // TO-DO move inventory update to MissionReturnTask execute()
                // items and injuries are sent to player after mission return complete
                svc.inventory.updateInventory { items ->
                    items.combineItems(
                        combinedLootedItems.filter { !GlobalContext.gameDefinitions.isResourceItem(it.type) },
                        GlobalContext.gameDefinitions
                    )
                }

                svc.compound.updateResource { currentRes ->
                    // Cap resources at storage limit (default 100 per resource type)
                    val storageLimit = 100 // TODO: Get actual limit from GameDefinitions based on storage buildings
                    val cappedResources = GameResources(
                        wood = minOf(currentRes.wood + obtainedResources.wood, storageLimit),
                        metal = minOf(currentRes.metal + obtainedResources.metal, storageLimit),
                        cloth = minOf(currentRes.cloth + obtainedResources.cloth, storageLimit),
                        water = minOf(currentRes.water + obtainedResources.water, storageLimit),
                        food = minOf(currentRes.food + obtainedResources.food, storageLimit),
                        ammunition = minOf(currentRes.ammunition + obtainedResources.ammunition, storageLimit),
                        cash = currentRes.cash + obtainedResources.cash // Cash has no limit
                    )
                    cappedResources
                }

                val returnTime = 20.seconds

                val responseJson = GlobalContext.json.encodeToString(
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

                        // itmCounters is not related to item quantity
                        // it is some kind of internal weapon state (i.e., kill count)
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

                val resourceResponseJson = GlobalContext.json.encodeToString(svc.compound.getResources())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))

                // TO-DO update player's task collection to include the mission return task
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
                // usually requested during middle of mission
                // there could be 'rush' flag somewhere, which means we need to send runner zombies

                val zombies = listOf(
                    ZombieData.strongRunner(Random.nextInt()),
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                ).flatMap { it.toFlatList() }

                val responseJson = GlobalContext.json.encodeToString(
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
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_SPEED_UP' message [not implemented]" }

                // TO-DO implement mission speed up similar to building speed up
                // TO-DO don't forget to save mission as a task to DB (TaskCollection),
                // just like how building construction modify upgrade/repair timer in DB

                // temporarily always make speed up always success so player don't stuck
                val response: MissionSpeedUpResponse = MissionSpeedUpResponse("", true, 0)
                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                connection.sendMessage(NetworkMessage.MISSION_RETURN_COMPLETE, connection.playerId)
            }

            SaveDataMethod.MISSION_SCOUTED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_SCOUTED' message [not implemented]" }
            }

            SaveDataMethod.MISSION_ITEM_USE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_ITEM_USE' message [not implemented]" }
            }

            SaveDataMethod.MISSION_TRIGGER -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_TRIGGER' message [not implemented]" }
            }

            SaveDataMethod.MISSION_ELITE_SPAWNED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_ELITE_SPAWNED' message [not implemented]" }
            }

            SaveDataMethod.MISSION_ELITE_KILLED -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'MISSION_ELITE_KILLED' message [not implemented]" }
            }

            // also handle this
            SaveDataMethod.STAT_DATA -> {
                val playerStats = parseMissionStats(data["stats"])
                Logger.debug(logFull = true) { "STAT_DATA parsed: $playerStats" }
                missionStats[connection.playerId] = playerStats
                // TODO: attach missionStats to a running mission context or persist if needed
            }

            SaveDataMethod.STAT -> {
                val playerStats = parseMissionStats(data["stats"])
                Logger.debug(logFull = true) { "STAT parsed: $missionStats" }
                missionStats[connection.playerId] = playerStats
                // TODO: attach missionStats to a running mission context or persist if needed
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
            if (GlobalContext.gameDefinitions.isResourceItem(item.type)) {
                val resAmount = GlobalContext.gameDefinitions.getResourceAmount(item.type)
                if (resAmount != null) {
                    totalRes += resAmount
                } else {
                    Logger.warn { "Unexpected scenario: item=${item.compactString()} was classified as resource item but getResourceAmount returns null" }
                }
            }
        }

        return items.stackOwnItems(GlobalContext.gameDefinitions) to totalRes
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
        var totalXp = 50
        totalXp += (killData["zombie"] ?: 0) * 5
        totalXp += (killData["runner"] ?: 0) * 10
        totalXp += (killData["fatty"] ?: 0) * 15
        totalXp += (killData["boss"] ?: 0) * 100
        return totalXp.coerceAtMost(1000)
    }
}
