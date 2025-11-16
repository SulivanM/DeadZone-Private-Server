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
import core.model.game.data.plus
import core.model.game.data.ZombieData
import core.model.game.data.toFlatList
import core.model.game.data.assignment.AssignmentResult
import dev.deadzone.core.model.game.data.TimerData
import dev.deadzone.core.model.game.data.reduceBy
import dev.deadzone.core.model.game.data.reduceByHalf
import dev.deadzone.core.model.game.data.secondsLeftToEnd
import server.handler.save.SaveHandlerContext
import server.tasks.impl.MissionReturnTask
import server.tasks.impl.MissionReturnStopParameter
import io.ktor.util.date.*
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.mission.response.*
import server.messaging.NetworkMessage
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import server.tasks.TaskCategory
import common.JSON
import common.LogConfigSocketError
import common.LogConfigSocketToClient
import common.Logger
import core.game.SpeedUpCostCalculator
import common.UUID
import core.survivor.XpLevelService
import core.survivor.model.injury.Injury
import core.bounty.BountyService
import server.service.InjuryService
import kotlin.math.pow
import kotlin.random.Random
import kotlin.time.Duration
import kotlin.time.Duration.Companion.hours
import kotlin.time.Duration.Companion.seconds
import kotlin.time.DurationUnit

// Data class to track survivor XP/level during mission
private data class MissionSurvivorData(
    val id: String,
    val startXP: Int,
    val startLevel: Int
)

// Data class to track mission state
private data class MissionState(
    val missionId: String,
    val insertedLoots: List<LootContent>,
    val survivors: List<MissionSurvivorData>,
    val areaType: String,
    val assignmentId: String? = null,
    val assignmentType: String? = null,
    val isCompound: Boolean = false,
    val isPvP: Boolean = false,
    val opponentId: String? = null
)

class MissionSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.MISSION_SAVES

    // save stats of playerId: MissionStats
    // use this to know loots, EXP, kills, etc. after mission ended.
    private val missionStats: MutableMap<String, MissionStats> = mutableMapOf()

    // when player start a mission, store mission state including survivors
    // maps playerId to MissionState
    private val activeMissions = mutableMapOf<String, MissionState>()

    // track active mission return tasks for speedup
    // maps missionId to (playerId, startTime, returnDuration)
    private val missionReturnTasks = mutableMapOf<String, Triple<String, Long, Int>>()

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId
        when (type) {
            SaveDataMethod.MISSION_START -> {
                // IMPORTANT NOTE: the scene that involves human model is not working now (e.g., raid island human)
                // the same error is for survivor class if you fill SurvivorAppearance non-null value
                // The error was 'cyclic object' thing.
                val isCompoundZombieAttack = data["compound"]?.equals(true)
                val areaType = if (isCompoundZombieAttack == true) "compound" else data["areaType"] as String

                // Check if this is an automated mission
                val isAutomated = data["automated"] as? Boolean ?: false
                Logger.info(LogConfigSocketToClient) { "Going to scene with areaType=$areaType, automated=$isAutomated" }

                val svc = serverContext.requirePlayerContext(playerId).services
                val leader = svc.survivor.getSurvivorLeader()

                // Extract survivors data from client request
                val survivorsData = (data["survivors"] as? List<*>)?.mapNotNull { survivorObj ->
                    val survivorMap = survivorObj as? Map<*, *> ?: return@mapNotNull null
                    MissionSurvivorData(
                        id = survivorMap["id"] as? String ?: return@mapNotNull null,
                        startXP = (survivorMap["startXP"] as? Number)?.toInt() ?: 0,
                        startLevel = (survivorMap["startLevel"] as? Number)?.toInt() ?: 1
                    )
                } ?: emptyList()

                // temporarily use player's ID as missionId itself
                // this enables deterministic ID therefore can avoid memory leak
                // later, should save the missionId as task to DB in MISSION_END
                val missionId = connection.playerId

                if (isAutomated) {
                    // AUTOMATED MISSION PATH - no client gameplay
                    // Client calls onMissionEndSaved() with the MISSION_START response for automated missions
                    // See MissionData.as line 744-745
                    Logger.info(LogConfigSocketToClient) { "Processing automated mission for playerId=$playerId" }

                    // Read combat scores from client (used for success calculation)
                    val survivorScore = (data["srvScore"] as? Number)?.toDouble() ?: 100.0
                    val enemyScore = (data["enmScore"] as? Number)?.toDouble() ?: 100.0

                    // Calculate success probability (clamped between 1% and 95%)
                    val rawChance = survivorScore / (survivorScore + enemyScore)
                    val successChance = rawChance.coerceIn(0.01, 0.95)

                    // Determine mission outcome
                    val missionSuccess = Random.nextDouble() < successChance
                    Logger.info(LogConfigSocketToClient) {
                        "Automated mission: survivorScore=$survivorScore, enemyScore=$enemyScore, " +
                        "successChance=${(successChance * 100).toInt()}%, success=$missionSuccess"
                    }

                    // Calculate XP earned (reduced for automated missions)
                    val areaLevel = (data["areaLevel"] as? Int) ?: 0
                    val baseXp = calculateMissionXp(
                        killData = mapOf(
                            "standard-kills" to (3 + Random.nextInt(3)),  // 3-5 standard zombies
                            "dog-kills" to Random.nextInt(2)  // 0-1 dog
                        ),
                        areaLevel = areaLevel
                    )
                    // Automated missions give reduced XP (50-75%)
                    val earnedXp = (baseXp * Random.nextDouble(0.5, 0.75)).toInt()

                    // Generate loot if mission successful
                    val rawLootedItems = if (missionSuccess) {
                        // Load scene to generate loot containers (but don't send to client)
                        val sceneXMLForLoot = resolveAndLoadScene(areaType)
                        if (sceneXMLForLoot != null) {
                            val lootParameter = LootParameter(
                                areaLevel = areaLevel,
                                playerLevel = leader.level,
                                itemWeightOverrides = mapOf(),
                                specificItemBoost = mapOf(
                                    "fuel-bottle" to 3.0,
                                    "fuel-container" to 3.0,
                                    "fuel" to 3.0,
                                    "fuel-cans" to 3.0,
                                ),
                                itemTypeBoost = mapOf(
                                    "junk" to 0.8
                                ),
                                itemQualityBoost = mapOf(
                                    "blue" to 0.5
                                ),
                                baseWeight = 1.0,
                                fuelLimit = 50
                            )
                            val lootService = LootService(sceneXMLForLoot, lootParameter)
                            val (_, loots) = lootService.insertLoots()
                            // For automated missions, give player 30-70% of available loot
                            val lootPercentage = Random.nextDouble(0.3, 0.7)
                            loots.shuffled().take((loots.size * lootPercentage).toInt())
                        } else {
                            Logger.warn(LogConfigSocketToClient) { "Could not load scene for automated loot generation: $areaType" }
                            emptyList()
                        }
                    } else {
                        // Mission failed - no loot
                        emptyList()
                    }

                    // Convert loot contents to items
                    val lootItems = rawLootedItems.map { lootContent ->
                        Item(id = UUID.new(), type = lootContent.itemIdInXML, qty = lootContent.quantity.toUInt(), new = true)
                    }

                    // Process loot into inventory items and resources
                    val (combinedLootedItems, obtainedResources) = buildInventoryAndResource(lootItems)

                    // Load PlayerObjects to access restXP
                    var playerObjectsUpdate = serverContext.db.loadPlayerObjects(playerId)
                    if (playerObjectsUpdate == null) {
                        Logger.error(LogConfigSocketError) { "Failed to load PlayerObjects for playerId=$playerId" }
                        return
                    }

                    // Use centralized XP service to add XP to leader with rested XP bonus
                    val (updatedLeader, updatedPlayerObjects) = XpLevelService.addXpToLeader(
                        survivor = leader,
                        playerObjects = playerObjectsUpdate,
                        earnedXp = earnedXp
                    )

                    val newLevel = updatedLeader.level
                    val newXp = updatedLeader.xp
                    val newLevelPts = (newLevel - leader.level).coerceAtLeast(0)

                    // Update the leader's XP and level in database
                    val leaderUpdateResult = svc.survivor.updateSurvivor(leader.id) { _ ->
                        updatedLeader
                    }
                    if (leaderUpdateResult.isFailure) {
                        Logger.error(LogConfigSocketError) { "Failed to update leader XP/level for playerId=$playerId: ${leaderUpdateResult.exceptionOrNull()?.message}" }
                        return
                    }

                    // Update PlayerObjects with new levelPts and consumed restXP
                    val persistResult = runCatching {
                        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                    }
                    if (persistResult.isFailure) {
                        Logger.error(LogConfigSocketError) {
                            "Failed to persist PlayerObjects for playerId=$playerId: ${persistResult.exceptionOrNull()?.message}"
                        }
                    }

                    // Update reference
                    playerObjectsUpdate = updatedPlayerObjects

                    // Update player's inventory and resources
                    val inventoryUpdateResult = svc.inventory.updateInventory { items ->
                        items.combineItems(
                            combinedLootedItems.filter { !GameDefinition.isResourceItem(it.type) },
                            GameDefinition
                        )
                    }
                    if (inventoryUpdateResult.isFailure) {
                        Logger.error(LogConfigSocketError) { "Failed to update inventory for playerId=$playerId: ${inventoryUpdateResult.exceptionOrNull()?.message}" }
                        return
                    }

                    val storageLimit = svc.compound.getStorageLimit()
                    val resourceUpdateResult = svc.compound.updateResource { currentRes ->
                        GameResources(
                            wood = minOf(currentRes.wood + obtainedResources.wood, storageLimit),
                            metal = minOf(currentRes.metal + obtainedResources.metal, storageLimit),
                            cloth = minOf(currentRes.cloth + obtainedResources.cloth, storageLimit),
                            water = minOf(currentRes.water + obtainedResources.water, storageLimit),
                            food = minOf(currentRes.food + obtainedResources.food, storageLimit),
                            ammunition = minOf(currentRes.ammunition + obtainedResources.ammunition, storageLimit),
                            cash = currentRes.cash + obtainedResources.cash
                        )
                    }
                    if (resourceUpdateResult.isFailure) {
                        Logger.error(LogConfigSocketError) { "Failed to update resources for playerId=$playerId: ${resourceUpdateResult.exceptionOrNull()?.message}" }
                        return
                    }

                    // Calculate survivor XP gains
                    val survivorResults = survivorsData.map { survivorData ->
                        val currentSurvivor = svc.survivor.getSurvivor(survivorData.id)
                        if (currentSurvivor == null) {
                            Logger.error(LogConfigSocketError) { "Survivor ${survivorData.id} not found" }
                            return@map SurvivorResult(
                                id = survivorData.id,
                                morale = null,
                                xp = survivorData.startXP,
                                level = survivorData.startLevel
                            )
                        }

                        val xpGainResult = XpLevelService.addXpToSurvivor(
                            survivor = currentSurvivor,
                            earnedXp = earnedXp,
                            availableRestedXp = 0
                        )

                        val updateResult = svc.survivor.updateSurvivor(survivorData.id) { _ ->
                            xpGainResult.updatedSurvivor
                        }
                        if (updateResult.isFailure) {
                            Logger.error(LogConfigSocketError) {
                                "Failed to update survivor ${survivorData.id}: ${updateResult.exceptionOrNull()?.message}"
                            }
                        }

                        SurvivorResult(
                            id = survivorData.id,
                            morale = null,
                            xp = xpGainResult.updatedSurvivor.xp,
                            level = xpGainResult.updatedSurvivor.level
                        )
                    }

                    // Get total levelPts for client
                    val playerObjectsForResponse = serverContext.db.loadPlayerObjects(playerId)
                    val totalLevelPts = playerObjectsForResponse?.levelPts?.toInt() ?: newLevelPts

                    // Automated missions have increased return time (1.5-2x multiplier)
                    val baseTimeSeconds = if (isCompoundZombieAttack == true) 30 else 240
                    val automatedTimeMultiplier = 1.5
                    val timeSeconds = (baseTimeSeconds * automatedTimeMultiplier).toInt()
                    val returnTime = timeSeconds.seconds

                    // Store mission state for tracking
                    activeMissions[connection.playerId] = MissionState(
                        missionId = missionId,
                        insertedLoots = rawLootedItems,
                        survivors = survivorsData,
                        areaType = areaType,
                        assignmentId = data["assignmentId"] as? String,
                        assignmentType = null,
                        isCompound = isCompoundZombieAttack == true,
                        isPvP = data["playerId"] != null,
                        opponentId = data["playerId"] as? String
                    )

                    // For automated missions, combine MISSION_START and MISSION_END response fields
                    // The client calls onMissionEndSaved() with this response (MissionData.as line 744-745)
                    val responseJson = JSON.encode(
                        MissionStartResponse(
                            // Mission Start fields
                            id = missionId,
                            time = timeSeconds,
                            assignmentType = "None",
                            areaClass = (data["areaClass"] as String?) ?: "",
                            automated = true,
                            sceneXML = "",
                            z = emptyList(),
                            allianceAttackerEnlisting = false,
                            allianceAttackerLockout = false,
                            allianceAttackerAllianceId = null,
                            allianceAttackerAllianceTag = null,
                            allianceMatch = false,
                            allianceRound = 0,
                            allianceRoundActive = false,
                            allianceError = false,
                            allianceAttackerWinPoints = 0,
                            
                            // Mission End fields (for automated missions)
                            xpEarned = earnedXp,
                            xp = XpBreakdown(total = earnedXp),
                            returnTimer = TimerData.runForDuration(
                                duration = returnTime,
                                data = mapOf("return" to timeSeconds)
                            ),
                            lockTimer = null,
                            loot = combinedLootedItems,
                            itmCounters = emptyMap(),
                            injuries = null,
                            survivors = survivorResults,
                            player = PlayerSurvivor(xp = newXp, level = newLevel),
                            levelPts = totalLevelPts,
                            cooldown = null,
                            stats = null,
                            bountyCollect = false,
                            bounty = null,
                            allianceFlagCaptured = false,
                            bountyCap = null,
                            bountyCapTimestamp = null,
                            assignmentresult = null
                        )
                    )

                    val resourceResponseJson = JSON.encode(svc.compound.getResources())
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)), logFull = false)

                } else {
                    // MANUAL MISSION PATH - client plays the mission
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
                    val lootService = LootService(sceneXML, lootParameter)
                    val (sceneXMLWithLoot, insertedLoots) = lootService.insertLoots()

                    val zombies = listOf(
                        ZombieData.standardZombieWeakAttack(Random.nextInt()),
                        ZombieData.standardZombieWeakAttack(Random.nextInt()),
                        ZombieData.dogStandard(Random.nextInt()),
                        ZombieData.fatWalkerStrongAttack(Random.nextInt()),
                    ).flatMap { it.toFlatList() }

                    val timeSeconds = if (isCompoundZombieAttack == true) 30 else 240

                    activeMissions[connection.playerId] = MissionState(
                        missionId = missionId,
                        insertedLoots = insertedLoots,
                        survivors = survivorsData,
                        areaType = areaType,
                        assignmentId = data["assignmentId"] as? String,
                        assignmentType = null,  // Will be set by server in response
                        isCompound = isCompoundZombieAttack == true,
                        isPvP = data["playerId"] != null,
                        opponentId = data["playerId"] as? String
                    )

                    val responseJson = JSON.encode(
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
                val areaLevel = data["areaLevel"] as? Int ?: 0
                val earnedXp = calculateMissionXp(playerStats.killData, areaLevel)

                // Update lifetime stats for quest tracking
                val playerObjects = serverContext.db.loadPlayerObjects(playerId)
                if (playerObjects != null) {
                    val currentLifetimeStats = playerObjects.lifetimeStats ?: MissionStats()
                    val updatedLifetimeStats = currentLifetimeStats.plus(playerStats)
                    val updatedPlayerObjects = playerObjects.copy(lifetimeStats = updatedLifetimeStats)
                    val updateResult = runCatching {
                        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                    }
                    if (updateResult.isFailure) {
                        Logger.error(LogConfigSocketError) {
                            "Failed to update lifetime stats for playerId=$playerId: ${updateResult.exceptionOrNull()?.message}"
                        }
                    }
                }

                val missionState = requireNotNull(activeMissions[connection.playerId]) {
                    "Mission state for playerId=$playerId was somehow null in MISSION_END request."
                }
                val missionId = missionState.missionId
                val insertedLoots = missionState.insertedLoots
                val missionSurvivors = missionState.survivors
                val areaType = missionState.areaType
                val assignmentId = missionState.assignmentId
                val isPvP = missionState.isPvP
                val isCompound = missionState.isCompound

                // Update bounty progress if player has an active bounty
                updateBountyProgress(playerId, areaType, playerStats.killData)

                val rawLootedItems = summarizeLoots(data, insertedLoots)
                val (combinedLootedItems, obtainedResources) = buildInventoryAndResource(rawLootedItems)

                // Load PlayerObjects to access restXP and update levelPts
                var playerObjectsUpdate = serverContext.db.loadPlayerObjects(playerId)
                if (playerObjectsUpdate == null) {
                    Logger.error(LogConfigSocketError) { "Failed to load PlayerObjects for playerId=$playerId" }
                    return
                }

                // Use centralized XP service to add XP to leader with rested XP bonus
                val (updatedLeader, updatedPlayerObjects) = XpLevelService.addXpToLeader(
                    survivor = leader,
                    playerObjects = playerObjectsUpdate,
                    earnedXp = earnedXp
                )

                val newLevel = updatedLeader.level
                val newXp = updatedLeader.xp
                val newLevelPts = (newLevel - leader.level).coerceAtLeast(0)

                // Update the leader's XP and level in database via SurvivorService
                val leaderUpdateResult = svc.survivor.updateSurvivor(leader.id) { _ ->
                    updatedLeader
                }
                if (leaderUpdateResult.isFailure) {
                    Logger.error(LogConfigSocketError) { "Failed to update leader XP/level for playerId=$playerId: ${leaderUpdateResult.exceptionOrNull()?.message}" }
                    return
                }

                // Update PlayerObjects with new levelPts and consumed restXP
                val persistResult = runCatching {
                    serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                }
                if (persistResult.isFailure) {
                    Logger.error(LogConfigSocketError) {
                        "Failed to persist PlayerObjects for playerId=$playerId: ${persistResult.exceptionOrNull()?.message}"
                    }
                }

                // Update reference for later use
                playerObjectsUpdate = updatedPlayerObjects

                // Get player profile once for all broadcasts
                val playerProfile = serverContext.playerAccountRepository.getProfileOfPlayerId(connection.playerId).getOrNull()
                val playerName = playerProfile?.displayName ?: connection.playerId

                // Broadcast level up if player leveled up
                if (newLevelPts > 0) {
                    runCatching {
                        BroadcastService.broadcastUserLevel(playerName, newLevel)
                    }.onFailure { e ->
                        Logger.error(LogConfigSocketError) {
                            "Failed to broadcast level up for playerId=$playerId (level $newLevel): ${e.message}"
                        }
                    }
                }

                // Broadcast rare items found (legendary and epic)
                combinedLootedItems.forEach { item ->
                    val quality = item.quality?.toString() ?: ""
                    if (quality.equals("legendary", ignoreCase = true) || quality.equals("epic", ignoreCase = true)) {
                        runCatching {
                            BroadcastService.broadcastItemFound(playerName, item.type, quality)
                        }.onFailure { e ->
                            Logger.error(LogConfigSocketError) {
                                "Failed to broadcast item found for playerId=$playerId (${item.type}): ${e.message}"
                            }
                        }
                    }
                }

                // Update player's inventory
                // TO-DO move inventory update to MissionReturnTask execute()
                // items and injuries are sent to player after mission return complete
                val inventoryUpdateResult = svc.inventory.updateInventory { items ->
                    items.combineItems(
                        combinedLootedItems.filter { !GameDefinition.isResourceItem(it.type) },
                        GameDefinition
                    )
                }
                if (inventoryUpdateResult.isFailure) {
                    Logger.error(LogConfigSocketError) { "Failed to update inventory for playerId=$playerId: ${inventoryUpdateResult.exceptionOrNull()?.message}" }
                    return
                }

                val resourceUpdateResult = svc.compound.updateResource { currentRes ->
                    // Cap resources at storage limit based on storage buildings
                    val storageLimit = svc.compound.getStorageLimit()
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
                if (resourceUpdateResult.isFailure) {
                    Logger.error(LogConfigSocketError) { "Failed to update resources for playerId=$playerId: ${resourceUpdateResult.exceptionOrNull()?.message}" }
                    return
                }

                // Calculate survivor XP gains and level ups using centralized service
                val survivorResults = missionSurvivors.map { survivorData ->
                    // Get the current survivor from the service
                    val currentSurvivor = svc.survivor.getSurvivor(survivorData.id)
                    if (currentSurvivor == null) {
                        Logger.error(LogConfigSocketError) { "Survivor ${survivorData.id} not found" }
                        // Return empty result for missing survivor
                        return@map SurvivorResult(
                            id = survivorData.id,
                            morale = null,
                            xp = survivorData.startXP,
                            level = survivorData.startLevel
                        )
                    }

                    // Use centralized XP service to add XP (no rested bonus for non-leader survivors)
                    val xpGainResult = XpLevelService.addXpToSurvivor(
                        survivor = currentSurvivor,
                        earnedXp = earnedXp,
                        availableRestedXp = 0  // Only leader gets rested XP bonus
                    )

                    val survivorNewXp = xpGainResult.updatedSurvivor.xp
                    val survivorNewLevel = xpGainResult.updatedSurvivor.level

                    // Update survivor in database via SurvivorService
                    val updateResult = svc.survivor.updateSurvivor(survivorData.id) { _ ->
                        xpGainResult.updatedSurvivor
                    }
                    if (updateResult.isFailure) {
                        Logger.error(LogConfigSocketError) {
                            "Failed to update survivor ${survivorData.id}: ${updateResult.exceptionOrNull()?.message}"
                        }
                    }

                    // Return survivor result for client
                    SurvivorResult(
                        id = survivorData.id,
                        morale = null, // Morale is handled separately if needed
                        xp = survivorNewXp,
                        level = survivorNewLevel
                    )
                }

                // Get total levelPts (not just new ones) for client
                val playerObjectsForResponse = serverContext.db.loadPlayerObjects(playerId)
                val totalLevelPts = playerObjectsForResponse?.levelPts?.toInt() ?: newLevelPts

                // Generate injuries for downed survivors
                val srvDownData = data["srvDown"] as? List<Map<String, Any?>> ?: emptyList<Map<String, Any?>>()
                val injuries = if (srvDownData.isNotEmpty()) {
                    generateInjuries(srvDownData)
                } else {
                    null
                }
                
                // Generate item counters from weapon usage statistics
                val itmCounters = generateItemCounters(data, playerStats)
                
                // Generate cooldown data if needed
                val cooldownData = generateCooldownData(playerId, assignmentId)
                
                // Handle PvP-specific data
                val bountyCollect = if (isPvP) {
                    data["bountyCollect"] as? Boolean ?: false
                } else {
                    false
                }
                
                // Handle Assignment Result (Raid/Arena)
                val assignmentResult = if (assignmentId != null) {
                    // Determine assignment type from client data or default to None
                    val assignmentType = data["assignmentType"] as? String ?: "None"
                    AssignmentResult(
                        id = assignmentId,
                        type = assignmentType
                    )
                } else {
                    null
                }

                val returnTime = 20.seconds

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

                        // Item counters for tracking weapon/item usage (kill counts, etc.)
                        itmCounters = itmCounters,
                        
                        // Injuries generated from srvDown data
                        injuries = injuries,
                        
                        survivors = survivorResults,
                        player = PlayerSurvivor(
                            xp = newXp,
                            level = newLevel
                        ),
                        levelPts = totalLevelPts,  // Send TOTAL levelPts, not just new ones
                        cooldown = cooldownData,  // Base64-encoded cooldown data
                        stats = playerStats,  // Include mission statistics for client display
                        
                        // PvP-specific fields
                        bountyCollect = bountyCollect,
                        bounty = null,  // Would be calculated based on PvP result
                        allianceFlagCaptured = false,  // Would be set based on mission objectives
                        bountyCap = null,
                        bountyCapTimestamp = null,
                        
                        // Assignment-specific (Raid/Arena)
                        assignmentresult = assignmentResult
                    )
                )

                val resourceResponseJson = JSON.encode(svc.compound.getResources())
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))

                // Save mission to database for history/quest tracking
                val completedMission = core.model.game.data.MissionData(
                    id = missionId,
                    player = core.model.game.data.SurvivorData(
                        id = leader.id,
                        startXP = leader.xp,
                        startLevel = leader.level,
                        endXP = newXp,
                        endLevel = newLevel
                    ),
                    stats = playerStats,
                    xpEarned = earnedXp,
                    xp = mapOf("total" to earnedXp),
                    completed = false, // Will be true after return timer completes
                    assignmentId = data["assignmentId"] as? String ?: "",
                    assignmentType = "None",
                    playerId = playerId,
                    compound = data["compound"] as? Boolean ?: false,
                    areaLevel = data["areaLevel"] as? Int ?: 0,
                    areaId = data["areaId"] as? String ?: "",
                    type = data["areaType"] as? String ?: "",
                    suburb = data["suburb"] as? String ?: "",
                    automated = data["automated"] as? Boolean ?: false,
                    survivors = missionSurvivors.map { mapOf("id" to it.id) },
                    srvDown = emptyList(),
                    buildingsDestroyed = emptyList(),
                    returnTimer = TimerData.runForDuration(
                        duration = returnTime,
                        data = mapOf("return" to returnTime.toInt(DurationUnit.SECONDS))
                    ),
                    lockTimer = null,
                    loot = combinedLootedItems,
                    highActivityIndex = data["highActivityIndex"] as? Int
                )

                // Update PlayerObjects with mission history
                val currentPlayerObjects = serverContext.db.loadPlayerObjects(playerId)
                if (currentPlayerObjects != null) {
                    val currentMissions = currentPlayerObjects.missions ?: emptyList()
                    val updatedMissions = currentMissions + completedMission
                    val updatedPlayerObjects = currentPlayerObjects.copy(missions = updatedMissions)

                    val saveMissionResult = runCatching {
                        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
                    }
                    if (saveMissionResult.isFailure) {
                        Logger.error(LogConfigSocketError) {
                            "Failed to save mission to database for playerId=$playerId: ${saveMissionResult.exceptionOrNull()?.message}"
                        }
                    } else {
                        Logger.info(LogConfigSocketToClient) {
                            "Mission $missionId saved to database. Total missions: ${updatedMissions.size}"
                        }
                    }
                }

                // Track mission return task for speedup
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
                            this.serverContext = serverContext
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
                // Client requests zombies during mission gameplay
                // Request contains: n (number), r (rush flag)
                // See ZombieDirector.as lines 591-615 and 672-688
                
                val numRequested = (data["n"] as? Number)?.toInt() ?: 2
                val isRush = data["r"] as? Boolean ?: false
                
                Logger.info(LogConfigSocketToClient) { 
                    "MISSION_ZOMBIES request: num=$numRequested, rush=$isRush" 
                }
                
                // Generate zombies based on request
                val zombies = if (isRush) {
                    // Rush mode: Send mostly fast zombies (runners)
                    List(numRequested) { 
                        when (Random.nextInt(100)) {
                            in 0..70 -> ZombieData.strongRunner(Random.nextInt())
                            in 71..85 -> ZombieData.standardZombieWeakAttack(Random.nextInt())
                            else -> ZombieData.dogStandard(Random.nextInt())
                        }
                    }
                } else {
                    // Normal mode: Mix of zombie types
                    List(numRequested) {
                        when (Random.nextInt(100)) {
                            in 0..50 -> ZombieData.standardZombieWeakAttack(Random.nextInt())
                            in 51..70 -> ZombieData.fatWalkerStrongAttack(Random.nextInt())
                            in 71..85 -> ZombieData.strongRunner(Random.nextInt())
                            else -> ZombieData.dogStandard(Random.nextInt())
                        }
                    }
                }.flatMap { it.toFlatList() }

                val responseJson = JSON.encode(
                    GetZombieResponse(
                        max = false,  // Set to true to disable server spawning
                        z = zombies
                    )
                )

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

                // Find the active mission return task for this player
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
                                -1 // Invalid
                            }
                        }
                        else -> {
                            Logger.warn { "Received unknown MissionSpeedUp option: $option from playerId=${connection.playerId}" }
                            -1 // Invalid
                        }
                    }

                    if (newRemainingSeconds >= 0) {
                        // Update resources
                        svc.compound.updateResource { resource ->
                            resourceResponse = resource.copy(cash = playerFuel - cost)
                            resourceResponse
                        }

                        // Stop the current mission return task
                        serverContext.taskDispatcher.stopTaskFor<MissionReturnStopParameter>(
                            connection = connection,
                            category = TaskCategory.Mission.Return,
                            stopInputBlock = {
                                this.missionId = missionId
                            }
                        )

                        if (newRemainingSeconds == 0) {
                            // Complete immediately - remove from tracking and force complete
                            missionReturnTasks.remove(missionId)
                            
                            // Send mission return complete message
                            connection.sendMessage(NetworkMessage.MISSION_RETURN_COMPLETE, missionId)
                        } else {
                            // Partial speedup - update tracking and restart with new duration
                            val newStartTime = getTimeMillis()
                            missionReturnTasks[missionId] = Triple(connection.playerId, newStartTime, newRemainingSeconds)
                            
                            // Restart mission return task with reduced time
                            serverContext.taskDispatcher.runTaskFor(
                                connection = connection,
                                taskToRun = MissionReturnTask(
                                    taskInputBlock = {
                                        this.missionId = missionId
                                        this.returnTime = newRemainingSeconds.seconds
                                        this.serverContext = serverContext
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
                
                // Send fuel update if resources changed (successful mission speed-up)
                resourceResponse?.let { res ->
                    sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                }
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
                // missionStats are stored in memory during the mission and used when mission ends
            }

            SaveDataMethod.STAT -> {
                val playerStats = parseMissionStats(data["stats"])
                Logger.debug(logFull = true) { "STAT parsed: $missionStats" }
                missionStats[connection.playerId] = playerStats
                // missionStats are stored in memory during the mission and used when mission ends
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

    // DEPRECATED: Use XpLevelService.calculateLevelFromTotalXp instead
    // Keeping for backward compatibility during migration
    private fun calculateNewLevelAndPoints(currentLevel: Int, currentXp: Int, newXp: Int): Pair<Int, Int> {
        return XpLevelService.calculateLevelFromTotalXp(currentLevel, currentXp, newXp)
    }

    // DEPRECATED: Use XpLevelService.calculateXpForNextLevel instead
    // Keeping for backward compatibility during migration
    private fun calculateXpForNextLevel(currentLevel: Int): Int {
        return XpLevelService.calculateXpForNextLevel(currentLevel)
    }

    /**
     * Calculate XP earned from a mission based on kills.
     * 
     * Matches client formula from MissionDirector.as:
     * XP_per_kill = BASE_ZOMBIE_KILL_XP * (areaLevel + 2) * zombie_xp_multiplier
     * 
     * This ensures XP scales properly with area difficulty and prevents
     * excessive XP gain from low-level missions.
     * 
     * @param killData Map of kill types to counts (e.g., "standard-kills" -> 5)
     * @param areaLevel Level of the area/mission (0-based)
     * @return Total XP earned
     */
    private fun calculateMissionXp(killData: Map<String, Int>, areaLevel: Int): Int {
        // Match client constant from Config.as
        // Based on game balance analysis: ~5 XP base per kill ensures reasonable progression
        // Tutorial mission (4 zombies, level 1): 4 * 5 * 3 = 60 XP (~20% toward level 2)
        val BASE_ZOMBIE_KILL_XP = 5.0
        
        // Calculate XP multiplier based on area level (matches client formula)
        // Formula: (areaLevel + 2) ensures even level 0 areas give some XP
        val areaMultiplier = areaLevel + 2
        
        var totalXp = 0.0
        
        // Define zombie type XP multipliers (matching client xp_multiplier values)
        // These multiply with the base XP and area multiplier
        val zombieXpMultipliers = mapOf(
            "standard" to 1.0,
            "zombie" to 1.0,
            "dog" to 1.0,
            "runner" to 1.0,
            "strong-runner" to 1.0,
            "fatty" to 1.0,
            "fat-walker" to 1.0,
            "police-20" to 1.0,
            "riot-walker-37" to 1.0,
            "dog-tank" to 1.0,
            "boss" to 2.0  // Bosses get double XP
        )
        
        // Calculate XP for each kill type
        // Formula: BASE_XP * (areaLevel + 2) * zombie_multiplier
        for ((killType, count) in killData) {
            if (count <= 0) continue
            
            // Extract zombie type from kill type (e.g., "standard-kills" -> "standard")
            val zombieType = killType.removeSuffix("-kills").removeSuffix("-explosive-kills")
            val multiplier = zombieXpMultipliers[zombieType] ?: 1.0
            
            // Apply client formula
            val xpPerKill = BASE_ZOMBIE_KILL_XP * areaMultiplier * multiplier
            totalXp += xpPerKill * count
        }
        
        // Round to nearest integer
        return totalXp.toInt()
    }

    /**
     * Update bounty progress based on kills from a mission
     */
    private suspend fun SaveHandlerContext.updateBountyProgress(
        playerId: String,
        areaType: String,
        killData: Map<String, Int>
    ) {
        val bountyService = BountyService()

        // Load player objects to get current bounty
        val playerObjects = serverContext.db.loadPlayerObjects(playerId) ?: run {
            Logger.warn(LogConfigSocketToClient) { "Failed to load player objects for bounty update: $playerId" }
            return
        }

        // Check if player has an active bounty
        if (!bountyService.hasActiveBounty(playerObjects)) {
            Logger.debug { "Player $playerId has no active bounty, skipping bounty update" }
            return
        }

        val currentBounty = playerObjects.dzBounty ?: return

        // Get suburb from area type
        val suburb = bountyService.getSuburbFromAreaType(areaType)
        if (suburb == null) {
            Logger.debug { "No suburb found for areaType: $areaType, skipping bounty update" }
            return
        }

        Logger.info(LogConfigSocketToClient) {
            "Updating bounty progress for player $playerId in suburb $suburb with kills: $killData"
        }

        // Update bounty progress
        val updateResult = bountyService.updateBountyProgress(currentBounty, killData, suburb)
        if (updateResult == null) {
            Logger.debug { "No bounty update needed for player $playerId" }
            return
        }

        // Save updated bounty to database
        val updatedPlayerObjects = playerObjects.copy(dzBounty = updateResult.updatedBounty)
        val saveResult = runCatching {
            serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)
        }

        if (saveResult.isFailure) {
            Logger.error(LogConfigSocketError) {
                "Failed to save updated bounty for player $playerId: ${saveResult.exceptionOrNull()?.message}"
            }
            return
        }

        // Send BOUNTY_UPDATE message with all condition kills
        val updatedBountyId = updateResult.updatedBounty.id
        val allConditionKills = mutableListOf<Int>()
        for (task in updateResult.updatedBounty.tasks) {
            for (condition in task.conditions) {
                allConditionKills.add(condition.kills)
            }
        }
        sendMessage(NetworkMessage.BOUNTY_UPDATE, updatedBountyId, *allConditionKills.toTypedArray())

        // Send BOUNTY_TASK_CONDITION_COMPLETE messages for completed conditions
        for (completedCondition in updateResult.completedConditions) {
            Logger.info(LogConfigSocketToClient) {
                "Bounty condition completed: bountyId=${updatedBountyId}, " +
                "taskIndex=${completedCondition.taskIndex}, " +
                "conditionIndex=${completedCondition.conditionIndex}"
            }
            sendMessage(
                NetworkMessage.BOUNTY_TASK_CONDITION_COMPLETE,
                updatedBountyId,
                completedCondition.taskIndex,
                completedCondition.conditionIndex
            )
        }

        // Send BOUNTY_TASK_COMPLETE messages for completed tasks
        for (completedTask in updateResult.completedTasks) {
            Logger.info(LogConfigSocketToClient) {
                "Bounty task completed: bountyId=${updatedBountyId}, taskIndex=${completedTask.taskIndex}"
            }
            sendMessage(
                NetworkMessage.BOUNTY_TASK_COMPLETE,
                updatedBountyId,
                completedTask.taskIndex
            )
        }

        // Handle bounty completion
        if (updateResult.bountyCompleted != null) {
            val completion = updateResult.bountyCompleted!!
            Logger.info(LogConfigSocketToClient) {
                "Bounty completed: bountyId=${updatedBountyId}, reward=${completion.rewardItem.type}"
            }

            // Add reward item to player's inventory
            val playerContext = serverContext.requirePlayerContext(playerId)
            val inventoryResult = playerContext.services.inventory.updateInventory { items ->
                items + completion.rewardItem
            }

            if (inventoryResult.isFailure) {
                Logger.error(LogConfigSocketError) {
                    "Failed to add bounty reward to inventory for player $playerId: ${inventoryResult.exceptionOrNull()?.message}"
                }
            } else {
                // Send BOUNTY_COMPLETE message with reward item
                val rewardItemJson = JSON.encode(completion.rewardItem)
                sendMessage(
                    NetworkMessage.BOUNTY_COMPLETE,
                    updatedBountyId,
                    rewardItemJson
                )
            }
        }
    }
    
    /**
     * Generate injuries for downed survivors based on client data
     * 
     * The client sends srvDown array with:
     * - id: survivor ID (uppercase)
     * - c: damage cause (e.g., "zombie", "bite", "explosion")
     * - ap: already processed flag (true if survivor was downed during mission)
     * 
     * @param srvDownData Array of survivor down data from client
     * @return List of InjuryData for response
     */
    private fun generateInjuries(srvDownData: List<*>): List<InjuryData> {
        val injuries = mutableListOf<InjuryData>()
        
        for (downDataObj in srvDownData) {
            val downData = downDataObj as? Map<*, *> ?: continue
            
            val survivorId = (downData["id"] as? String)?.uppercase() ?: continue
            val cause = (downData["c"] as? String) ?: "unknown"
            val alreadyProcessed = downData["ap"] as? Boolean ?: false
            
            // Only generate injury if not already processed during mission
            if (!alreadyProcessed) {
                // Generate a major injury based on the cause
                val injury = generateInjuryForCause(cause)
                
                injuries.add(InjuryData(
                    srv = survivorId,
                    inj = injury,
                    success = false  // false means they survived (but are injured)
                ))
            }
        }
        
        return injuries
    }
    
    /**
     * Generate an appropriate injury based on the damage cause
     * 
     * @param cause Damage cause (e.g., "zombie", "bite", "explosion", "gunshot")
     * @return Generated Injury object
     */
    private fun generateInjuryForCause(cause: String): Injury {
        // Determine injury type and location based on cause
        val (type, location, severity) = when {
            cause.contains("bite", ignoreCase = true) -> Triple("bite", "arm", "major")
            cause.contains("explosion", ignoreCase = true) -> Triple("burn", "torso", "major")
            cause.contains("gunshot", ignoreCase = true) -> Triple("gunshot", "leg", "major")
            cause.contains("zombie", ignoreCase = true) -> Triple("bite", "arm", "major")
            cause.contains("fall", ignoreCase = true) -> Triple("fracture", "leg", "major")
            else -> Triple("bruise", "torso", "major")  // Default
        }
        
        // Try to get injury definition from InjuryService
        val injuryDef = InjuryService.getInjuryDefinition(type, location, severity)
        
        // If definition exists, use it; otherwise create a basic injury
        return if (injuryDef != null) {
            val healTime = injuryDef.healTime
            Injury(
                id = UUID.new(),
                type = type,
                location = location,
                severity = severity,
                damage = injuryDef.damage.toDouble(),
                morale = injuryDef.morale.toDouble(),
                timer = if (healTime > 0) {
                    TimerData.runForDuration(
                        duration = healTime.seconds,
                        data = mapOf("heal" to healTime)
                    )
                } else null
            )
        } else {
            // Fallback injury if not found in definitions
            Injury(
                id = UUID.new(),
                type = type,
                location = location,
                severity = severity,
                damage = 20.0,  // Default damage
                morale = -10.0, // Default morale penalty
                timer = TimerData.runForDuration(
                    duration = 3600.seconds,  // 1 hour default
                    data = mapOf("heal" to 3600)
                )
            )
        }
    }
    
    /**
     * Generate item counters from weapon usage and kill statistics
     * 
     * Item counters track usage statistics for items (mainly weapons).
     * The client uses these to increment counterValue on inventory items,
     * which can be displayed in the UI (e.g., "This weapon has killed 50 zombies").
     * 
     * @param data Client request data containing gunstat and kill data
     * @param stats Mission statistics with kill counts
     * @return Map of item IDs to counter increments
     */
    private fun generateItemCounters(data: Map<String, Any?>, stats: MissionStats): Map<String, Int> {
        val counters = mutableMapOf<String, Int>()
        
        // Process weapon statistics from gunstat
        val gunStats = data["gunstat"] as? List<*>
        if (gunStats != null) {
            for (statObj in gunStats) {
                val stat = statObj as? Map<*, *> ?: continue
                val weaponType = stat["type"] as? String ?: continue
                val longRangeHits = (stat["lrh"] as? Number)?.toInt() ?: 0
                
                // Weapon type would map to actual item IDs in a real implementation
                // For now, we'll use the weapon type as a placeholder
                // In a full implementation, you'd look up which weapons the survivors used
                if (longRangeHits > 0) {
                    // This is a simplified implementation
                    // In reality, you'd track which specific weapon items were used
                    Logger.debug { "Weapon $weaponType had $longRangeHits long range hits" }
                }
            }
        }
        
        // For now, return empty map since we don't have item ID tracking during missions
        // A full implementation would require tracking which specific inventory items
        // were used by survivors during the mission
        return counters
    }
    
    /**
     * Generate cooldown data for the mission
     * 
     * Cooldowns prevent players from repeating certain actions too quickly.
     * The client expects a Base64-encoded string of cooldown data.
     * 
     * @param playerId Player identifier
     * @param assignmentId Assignment identifier (if this is a raid/arena mission)
     * @return Base64-encoded cooldown string, or null if no cooldowns to set
     */
    private suspend fun SaveHandlerContext.generateCooldownData(
        playerId: String,
        assignmentId: String?
    ): String? {
        // Cooldowns are typically set for specific mission types or actions
        // For assignments (raids/arenas), there might be cooldowns between attempts
        
        // Load player objects to check existing cooldowns
        val playerObjects = serverContext.db.loadPlayerObjects(playerId)
        if (playerObjects == null) {
            Logger.warn(LogConfigSocketToClient) { "Could not load player objects for cooldown generation" }
            return null
        }
        
        // Check if there are cooldowns to encode
        val cooldownsMap = playerObjects.cooldowns
        if (cooldownsMap.isNullOrEmpty()) {
            return null
        }
        
        // The cooldown data is stored as Map<String, ByteArray>
        // We need to encode it to Base64 for transmission to client
        // For now, return null as we don't have active cooldown generation during missions
        // A full implementation would:
        // 1. Serialize the cooldown map to ByteArray
        // 2. Encode to Base64 string
        // 3. Return the encoded string
        return null
    }
}
