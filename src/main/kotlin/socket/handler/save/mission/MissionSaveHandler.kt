package socket.handler.save.mission

import context.GlobalContext
import context.ServerContext
import context.requirePlayerContext
import core.mission.LootService
import core.mission.model.LootParameter
import core.model.game.data.ZombieData
import core.model.game.data.toFlatList
import core.model.game.data.MissionStats
import socket.core.Connection
import socket.handler.buildMsg
import socket.handler.save.SaveSubHandler
import socket.handler.save.mission.response.*
import socket.messaging.SaveDataMethod
import socket.protocol.PIOSerializer
import utils.LogConfigSocketToClient
import utils.Logger
import kotlin.random.Random

class MissionSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.MISSION_SAVES

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
                val sceneXMLWithLoot = lootService.insertLoots()

                val zombies = listOf(
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                    ZombieData.dogStandard(Random.nextInt()),
                    ZombieData.dogStandard(Random.nextInt()),
                    ZombieData.fatWalkerStrongAttack(Random.nextInt()),
                ).flatMap { it.toFlatList() }

                val timeSeconds = if (isCompoundZombieAttack == true) 30 else 240

                val responseJson = GlobalContext.json.encodeToString(
                    MissionStartResponse(
                        id = saveId,
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

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
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

                // some of most important data
                val responseJson = GlobalContext.json.encodeToString(
                    MissionEndResponse(
                        automated = false,
                        xpEarned = 100,
                        xp = null,
                        returnTimer = null,
                        lockTimer = null,
                        loot = emptyList(),
                        // item id to quantity
                        itmCounters = emptyMap(),
                        injuries = null,
                        // the survivors that goes into the mission
                        survivors = emptyList(),
                        player = PlayerSurvivor(xp = 100, level = leader.level),
                        levelPts = 0,
                        // base64 encoded string
                        cooldown = null
                    )
                )

                // change resource with obtained loot...
                val currentResource = svc.compound.getResources()

                val resourceResponseJson = GlobalContext.json.encodeToString(currentResource)

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
            }

            SaveDataMethod.MISSION_ZOMBIES -> {
                // usually requested during middle of mission
                // there could be 'rush' flag somewhere, which means we need to send runner zombies

                val zombies = listOf(
                    ZombieData.strongRunner(Random.nextInt()),
                    ZombieData.strongRunner(Random.nextInt()),
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                    ZombieData.standardZombieWeakAttack(Random.nextInt()),
                    ZombieData.fatWalkerStrongAttack(104),
                    ZombieData.fatWalkerStrongAttack(105),
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
                val stats = data["stats"]
                Logger.debug(logFull = true) { data["stats"].toString() }
                Logger.warn(LogConfigSocketToClient) { "Received 'STAT_DATA' message on MissionSaveHandler [not implemented] with stats: $stats" }
                val missionStats = parseMissionStats(data["stats"])
                Logger.debug(logFull = true) { "STAT_DATA parsed: $missionStats" }
                // TODO: attach missionStats to a running mission context or persist if needed
            }
            SaveDataMethod.STAT -> {
                val stats = data["stats"]
                Logger.debug(logFull = true) { data["stats"].toString() }
                Logger.warn(LogConfigSocketToClient) { "Received 'STAT_DATA' message on MissionSaveHandler [not implemented] with stats: $stats" }
                val missionStats = parseMissionStats(data["stats"])
                Logger.debug(logFull = true) { "STAT parsed: $missionStats" }
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
}