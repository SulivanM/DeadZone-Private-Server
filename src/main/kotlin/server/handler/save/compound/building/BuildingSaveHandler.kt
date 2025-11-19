package server.handler.save.compound.building

import context.requirePlayerContext
import core.data.GameDefinition
import core.model.game.data.*
import dev.deadzone.core.model.game.data.TimerData
import dev.deadzone.core.model.game.data.reduceBy
import dev.deadzone.core.model.game.data.reduceByHalf
import dev.deadzone.core.model.game.data.secondsLeftToEnd
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.compound.building.response.*
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import server.tasks.TaskCategory
import server.tasks.impl.BuildingCreateStopParameter
import server.tasks.impl.BuildingCreateTask
import server.tasks.impl.BuildingRepairStopParameter
import server.tasks.impl.BuildingRepairTask
import core.survivor.XpLevelService
import common.JSON
import common.LogConfigSocketError
import common.LogConfigSocketToClient
import common.Logger
import core.game.SpeedUpCostCalculator
import server.broadcast.BroadcastService
import core.data.resources.BuildingResource
import core.data.resources.BuildingLevelItem
import kotlin.math.min
import kotlin.time.Duration
import kotlin.time.Duration.Companion.hours
import kotlin.time.Duration.Companion.seconds
import kotlin.time.DurationUnit
import kotlin.time.toDuration

class BuildingSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.COMPOUND_BUILDING_SAVES

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        val playerId = connection.playerId
        val svc = serverContext.requirePlayerContext(playerId).services.compound

        when (type) {
            SaveDataMethod.BUILDING_CREATE -> {
                val bldId = data["id"] as? String ?: return
                val bldType = data["type"] as? String ?: return
                val x = data["tx"] as? Int ?: return
                val y = data["ty"] as? Int ?: return
                val r = data["rotation"] as? Int ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_CREATE' message for $saveId and $bldId,$bldType to tx=$x, ty=$y, rotation=$r" }

                val buildingDef = GameDefinition.findBuilding(bldType)
                val levelDef = buildingDef?.getLevel(0)
                val buildTimeSeconds = levelDef?.time ?: 1444
                val buildDuration = buildTimeSeconds.seconds
                val xpEarned = levelDef?.xp ?: 50

                val timer = TimerData.runForDuration(
                    duration = buildDuration,
                    data = mapOf("level" to 0, "type" to "upgrade", "xp" to xpEarned)
                )

                val result = svc.createBuilding {
                    Building(
                        id = bldId,
                        name = null,
                        type = bldType,
                        level = 0,
                        rotation = r,
                        tx = x,
                        ty = y,
                        destroyed = false,
                        resourceValue = 0.0,
                        upgrade = timer,
                        repair = null
                    )
                }

                val response: BuildingCreateResponse
                if (result.isSuccess) {
                    response = BuildingCreateResponse(
                        success = true,
                        items = emptyMap(),
                        timer = timer
                    )
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to create building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    response = BuildingCreateResponse(
                        success = false,
                        items = emptyMap(),
                        timer = null
                    )
                }

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = BuildingCreateTask(
                            taskInputBlock = {
                                this.buildingId = bldId
                                this.buildDuration = buildDuration
                                this.serverContext = serverContext
                            },
                            stopInputBlock = {
                                this.buildingId = bldId
                            }
                        )
                    )
                }
            }

            SaveDataMethod.BUILDING_MOVE -> {
                val x = (data["tx"] as? Number)?.toInt() ?: return
                val y = (data["ty"] as? Number)?.toInt() ?: return
                val r = (data["rotation"] as? Number)?.toInt() ?: return
                val buildingId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'bld_move' message for $saveId and $buildingId to tx=$x, ty=$y, rotation=$r" }

                val result = svc.updateBuilding(buildingId) { it.copy(tx = x, ty = y, rotation = r) }

                val response: BuildingMoveResponse
                if (result.isSuccess) {
                    response = BuildingMoveResponse(success = true, x = x, y = y, r = r)
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to move building bldId=$buildingId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    response = BuildingMoveResponse(success = false, x = x, y = y, r = r)
                }

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_UPGRADE -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_UPGRADE' message for $saveId and $bldId" }

                lateinit var timer: TimerData
                val result = svc.updateBuilding(bldId) { bld ->
                    val nextLevel = bld.level + 1
                    val buildingDef = GameDefinition.findBuilding(bld.type)
                    val levelDef = buildingDef?.getLevel(nextLevel)
                    val buildTimeSeconds = levelDef?.time ?: 10
                    val xpEarned = levelDef?.xp ?: 50
                    val buildDuration = buildTimeSeconds.seconds

                    timer = TimerData.runForDuration(
                        duration = buildDuration,
                        data = mapOf("level" to nextLevel, "type" to "upgrade", "xp" to xpEarned)
                    )
                    bld.copy(upgrade = timer)
                }

                val response: BuildingUpgradeResponse
                if (result.isSuccess) {
                    response = BuildingUpgradeResponse(success = true, items = emptyMap(), timer = timer)
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to upgrade building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    response = BuildingUpgradeResponse(success = false, items = emptyMap(), timer = null)
                }

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = BuildingCreateTask(
                            taskInputBlock = {
                                this.buildingId = bldId
                                this.buildDuration = buildDuration
                                this.serverContext = serverContext
                            },
                            stopInputBlock = {
                                this.buildingId = bldId
                            }
                        )
                    )
                }
            }

            SaveDataMethod.BUILDING_RECYCLE -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_RECYCLE' message for $saveId and $bldId" }

                val result = svc.deleteBuilding(bldId)

                val response: BuildingRecycleResponse
                if (result.isSuccess) {
                    response = BuildingRecycleResponse(success = true, items = emptyMap())
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to recycle building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    response = BuildingRecycleResponse(success = false, items = emptyMap())
                }

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_COLLECT -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_COLLECT' message for $saveId and $bldId" }

                val collectResult = svc.collectBuilding(bldId)

                val response: BuildingCollectResponse
                if (collectResult.isSuccess) {
                    val res = collectResult.getOrThrow()
                    val resType =
                        requireNotNull(res.getNonEmptyResTypeOrNull()) { "Unexpected null on getNonEmptyResTypeOrNull during collect resource" }
                    val resAmount = requireNotNull(
                        res.getNonEmptyResAmountOrNull()?.toDouble()
                    ) { "Unexpected null on getNonEmptyResAmountOrNull during collect resource" }
                    val currentResource = svc.getResources()
                    val limit = svc.getStorageLimit().toDouble()
                    val expectedResource = currentResource.wood + resAmount
                    val remainder = expectedResource - limit
                    val total = min(limit, expectedResource)
                    response = BuildingCollectResponse(
                        success = true,
                        locked = false,
                        resource = resType,
                        collected = resAmount,
                        remainder = remainder,
                        total = total,
                        bonus = 0.0,
                        destroyed = false
                    )
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to collect building bldId=$bldId for playerId=$playerId: ${collectResult.exceptionOrNull()?.message}" }
                    response = BuildingCollectResponse(
                        success = false,
                        locked = false,
                        resource = "",
                        collected = 0.0,
                        remainder = 0.0,
                        total = 0.0,
                        bonus = 0.0,
                        destroyed = false
                    )
                }

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_CANCEL -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_CANCEL' message for $saveId and $bldId" }

                val result = svc.deleteBuilding(bldId)

                val response: BuildingCancelResponse
                if (result.isSuccess) {
                    response = BuildingCancelResponse(success = true, items = emptyMap())
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to cancel building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    response = BuildingCancelResponse(success = false, items = emptyMap())
                }

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_SPEED_UP -> {
                val bldId = data["id"] as? String ?: return
                val option = data["option"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_SPEED_UP' message for bldId=$bldId with option.key=$option" }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val playerFuel = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                val building =
                    requireNotNull(svc.compound.getBuilding(bldId)) { "Building bldId=$bldId was somehow null in BUILDING_SPEED_UP request for playerId=$playerId" }.toBuilding()
                val upgradeTimer =
                    requireNotNull(building.upgrade) { "Building upgrade timer for bldId=$bldId was somehow null in BUILDING_SPEED_UP request for playerId=$playerId" }

                val secondsRemaining = upgradeTimer.secondsLeftToEnd()

                val response: BuildingSpeedUpResponse
                var resourceResponse: GameResources? = null
                
                val (newBuilding, cost) = when (option) {
                        "SpeedUpOneHour" -> {
                            val calculatedCost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                            building.copy(upgrade = upgradeTimer.reduceBy(1.hours)) to calculatedCost
                        }

                        "SpeedUpTwoHour" -> {
                            val calculatedCost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                            building.copy(upgrade = upgradeTimer.reduceBy(2.hours)) to calculatedCost
                        }

                        "SpeedUpHalf" -> {
                            val calculatedCost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                            building.copy(upgrade = upgradeTimer.reduceByHalf()) to calculatedCost
                        }

                        "SpeedUpComplete" -> {
                            val calculatedCost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                            val newLevel = (upgradeTimer.data?.get("level") as? Int) ?: (building.level + 1)
                            building.copy(upgrade = null, level = newLevel) to calculatedCost
                        }

                        "SpeedUpFree" -> {
                            if (building.upgrade.secondsLeftToEnd() <= 300) {
                                val calculatedCost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                                val newLevel = (upgradeTimer.data?.get("level") as? Int) ?: (building.level + 1)
                                building.copy(upgrade = null, level = newLevel) to calculatedCost
                            } else {
                                Logger.warn { "Received unexpected BuildingSpeedUp FREE option: $option from playerId=${connection.playerId} (speed up requested when timer is off or build time more than 5 minutes)" }
                                null to null
                            }
                        }

                    else -> {
                        Logger.warn { "Received unknown BuildingSpeedUp option: $option from playerId=${connection.playerId}" }
                        null to null
                    }
                }

                if (newBuilding != null && cost != null) {
                    if (playerFuel < cost) {
                        response = BuildingSpeedUpResponse(error = notEnoughCoinsErrorId, success = false, cost = cost)
                    } else {
                        // successful response
                        val updateBuildingResult = svc.compound.updateBuilding(bldId) { newBuilding as BuildingLike }
                        val updateResourceResult = svc.compound.updateResource { resource ->
                            resourceResponse = resource.copy(cash = playerFuel - cost)
                            resourceResponse
                        }

                        // if for some reason DB fail, do not proceed the speed up request
                        response = if (updateBuildingResult.isFailure || updateResourceResult.isFailure) {
                            BuildingSpeedUpResponse(error = "", success = false, cost = 0)
                        } else {
                            BuildingSpeedUpResponse(error = "", success = true, cost = cost)
                        }

                        // end the currently active building task
                        serverContext.taskDispatcher.stopTaskFor<BuildingCreateStopParameter>(
                            connection = connection,
                            category = TaskCategory.Building.Create,
                            stopInputBlock = {
                                this.buildingId = bldId
                            }
                        )

                        // then restart it to change the timer
                        // if construction ended after the speed up, automatically start with zero second delay
                        serverContext.taskDispatcher.runTaskFor(
                            connection = connection,
                            taskToRun = BuildingCreateTask(
                                taskInputBlock = {
                                    this.buildingId = bldId
                                    this.buildDuration =
                                        newBuilding.upgrade
                                            ?.secondsLeftToEnd()
                                            ?.toDuration(DurationUnit.SECONDS)
                                            ?: Duration.ZERO
                                    this.serverContext = serverContext
                                },
                                stopInputBlock = {
                                    this.buildingId = bldId
                                }
                            )
                        )
                    }
                } else {
                    // unexpected DB error response
                    Logger.error(LogConfigSocketError) { "Failed to speed up create building bldId=$bldId for playerId=$playerId: old=${building.toCompactString()} new=${newBuilding?.toCompactString()}" }
                    response = BuildingSpeedUpResponse(error = "", success = false, cost = 0)
                }

                val responseJson = JSON.encode(response)
                val resourceResponseJson = JSON.encode(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
                
                // Send fuel update if resources changed (successful speed-up)
                resourceResponse?.let { res ->
                    sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                }
            }

            SaveDataMethod.BUILDING_REPAIR -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_REPAIR' message for $saveId and $bldId" }

                val building = svc.getBuilding(bldId)
                val buildingDef = building?.let { GameDefinition.findBuilding(it.type) }
                val levelDef = building?.let { buildingDef?.getLevel(it.level) }
                val repairTimeSeconds = levelDef?.time ?: 10
                val buildDuration = repairTimeSeconds.seconds

                val timer = TimerData.runForDuration(
                    duration = buildDuration,
                    data = mapOf("type" to "repair")
                )

                val result = svc.updateBuilding(bldId) { bld -> bld.copy(repair = timer) }

                val response: BuildingRepairResponse
                if (result.isSuccess) {
                    response = BuildingRepairResponse(success = true, items = emptyMap(), timer = timer)
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to repair building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    response = BuildingRepairResponse(success = false, items = emptyMap(), timer = null)
                }

                val responseJson = JSON.encode(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = BuildingRepairTask(
                            taskInputBlock = {
                                this.buildingId = bldId
                                this.repairDuration = buildDuration
                                this.serverContext = serverContext
                            },
                            stopInputBlock = {
                                this.buildingId = bldId
                            }
                        )
                    )
                }
            }

            SaveDataMethod.BUILDING_REPAIR_SPEED_UP -> {
                val bldId = data["id"] as? String ?: return
                val option = data["option"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_REPAIR_SPEED_UP' message for bldId=$bldId with option.key=$option" }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val playerFuel = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                val building =
                    requireNotNull(svc.compound.getBuilding(bldId)) { "Building bldId=$bldId was somehow null in BUILDING_REPAIR_SPEED_UP request for playerId=$playerId" }.toBuilding()
                val repairTimer =
                    requireNotNull(building.repair) { "Building repair timer for bldId=$bldId was somehow null in BUILDING_REPAIR_SPEED_UP request for playerId=$playerId" }

                val secondsRemaining = repairTimer.secondsLeftToEnd()

                var resourceResponse: GameResources? = null
                val response: BuildingRepairSpeedUpResponse
                
                val (newBuilding, cost) = when (option) {
                        "SpeedUpOneHour" -> {
                            val calculatedCost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                            building.copy(repair = repairTimer.reduceBy(1.hours)) to calculatedCost
                        }

                        "SpeedUpTwoHour" -> {
                            val calculatedCost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                            building.copy(repair = repairTimer.reduceBy(2.hours)) to calculatedCost
                        }

                        "SpeedUpHalf" -> {
                            val calculatedCost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                            building.copy(repair = repairTimer.reduceByHalf()) to calculatedCost
                        }

                        "SpeedUpComplete" -> {
                            val calculatedCost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                            building.copy(repair = null, destroyed = false) to calculatedCost
                        }

                        "SpeedUpFree" -> {
                            if (building.repair.secondsLeftToEnd() <= 300) {
                                val calculatedCost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                                building.copy(repair = null, destroyed = false) to calculatedCost
                            } else {
                                Logger.warn { "Received unexpected BuildingSpeedUp FREE option: $option from playerId=${connection.playerId} (speed up requested when timer is off or build time more than 5 minutes)" }
                                null to null
                            }
                        }

                    else -> {
                        Logger.warn { "Received unknown BuildingRepairSpeedUp option: $option from playerId=${connection.playerId}" }
                        null to null
                    }
                }

                if (newBuilding != null && cost != null) {
                    if (playerFuel < cost) {
                        response = BuildingRepairSpeedUpResponse(error = notEnoughCoinsErrorId, success = false, cost = cost)
                    } else {
                        // successful response
                        val updateBuildingResult = svc.compound.updateBuilding(bldId) { newBuilding as BuildingLike }
                        val updateResourceResult = svc.compound.updateResource { resource ->
                            resourceResponse = resource.copy(cash = playerFuel - cost)
                            resourceResponse
                        }

                        // if for some reason DB fail, do not proceed the speed up request
                        response = if (updateBuildingResult.isFailure || updateResourceResult.isFailure) {
                            BuildingRepairSpeedUpResponse(error = "", success = false, cost = 0)
                        } else {
                            BuildingRepairSpeedUpResponse(error = "", success = true, cost = cost)
                        }

                        // end the currently active building repair task
                        serverContext.taskDispatcher.stopTaskFor<BuildingRepairStopParameter>(
                            connection = connection,
                            category = TaskCategory.Building.Repair,
                            stopInputBlock = {
                                this.buildingId = bldId
                            }
                        )

                        // then restart it to change the timer
                        // if construction ended after the speed up, automatically start with zero second delay
                        serverContext.taskDispatcher.runTaskFor(
                            connection = connection,
                            taskToRun = BuildingRepairTask(
                                taskInputBlock = {
                                    this.buildingId = bldId
                                    this.repairDuration =
                                        newBuilding.repair
                                            ?.secondsLeftToEnd()
                                            ?.toDuration(DurationUnit.SECONDS)
                                            ?: Duration.ZERO
                                    this.serverContext = serverContext
                                },
                                stopInputBlock = {
                                    this.buildingId = bldId
                                }
                            )
                        )
                    }
                } else {
                    // unexpected DB error response
                    Logger.error(LogConfigSocketError) { "Failed to speed up repair building bldId=$bldId for playerId=$playerId: old=${building.toCompactString()} new=${newBuilding?.toCompactString()}" }
                    response = BuildingRepairSpeedUpResponse(error = "", success = false, cost = 0)
                }

                val responseJson = JSON.encode(response)
                val resourceResponseJson = JSON.encode(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
                
                // Send fuel update if resources changed (successful repair speed-up)
                resourceResponse?.let { res ->
                    sendMessage(server.messaging.NetworkMessage.FUEL_UPDATE, res.cash)
                }
            }

            SaveDataMethod.BUILDING_CREATE_BUY -> {
                val bldId = data["id"] as? String ?: return
                val bldType = data["type"] as? String ?: return
                val x = data["tx"] as? Int ?: return
                val y = data["ty"] as? Int ?: return
                val r = data["rotation"] as? Int ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_CREATE_BUY' message for $saveId and $bldId,$bldType to tx=$x, ty=$y, rotation=$r" }

                val svcPlayer = serverContext.requirePlayerContext(playerId).services
                val playerCash = svcPlayer.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                val buildingDef = GameDefinition.findBuilding(bldType)
                val levelDef = buildingDef?.getLevel(0)
                val xpEarned = levelDef?.xp ?: 50

                // Calculate instant purchase cost
                val buildCost = calculateBuildingCost(buildingDef, 0)

                var resourceResponse: GameResources? = null
                val response: BuildingCreateResponse

                if (playerCash < buildCost) {
                    response = BuildingCreateResponse(
                        success = false,
                        error = notEnoughCoinsErrorId,
                        items = emptyMap(),
                        timer = null,
                        cost = buildCost
                    )
                    Logger.warn(LogConfigSocketToClient) { "Not enough cash for instant building creation: required=$buildCost, available=$playerCash" }
                } else {
                    val buildDuration = 0.seconds
                    val timer = TimerData.runForDuration(
                        duration = buildDuration,
                        data = mapOf("level" to 0, "type" to "upgrade", "xp" to xpEarned)
                    )

                    val result = svc.createBuilding {
                        Building(
                            id = bldId,
                            name = null,
                            type = bldType,
                            level = 0,
                            rotation = r,
                            tx = x,
                            ty = y,
                            destroyed = false,
                            resourceValue = 0.0,
                            upgrade = timer,
                            repair = null
                        )
                    }

                    if (result.isSuccess) {
                        // Deduct cash
                        val updateResourceResult = svcPlayer.compound.updateResource { resource ->
                            resourceResponse = resource.copy(cash = playerCash - buildCost)
                            resourceResponse
                        }

                        if (updateResourceResult.isFailure) {
                            Logger.error(LogConfigSocketError) { "Failed to deduct cash for instant building creation playerId=$playerId: ${updateResourceResult.exceptionOrNull()?.message}" }
                            response = BuildingCreateResponse(
                                success = false,
                                error = "",
                                items = emptyMap(),
                                timer = null
                            )
                        } else {
                            response = BuildingCreateResponse(
                                success = true,
                                items = emptyMap(),
                                timer = timer,
                                cost = buildCost
                            )
                            Logger.info(LogConfigSocketToClient) { "Instant building created: bldId=$bldId, cost=$buildCost" }
                        }
                    } else {
                        Logger.error(LogConfigSocketError) { "Failed to create (buy) building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                        response = BuildingCreateResponse(
                            success = false,
                            items = emptyMap(),
                            timer = null
                        )
                    }

                    if (result.isSuccess && response.success) {
                        serverContext.taskDispatcher.runTaskFor(
                            connection = connection,
                            taskToRun = BuildingCreateTask(
                                taskInputBlock = {
                                    this.buildingId = bldId
                                    this.buildDuration = buildDuration
                                    this.serverContext = serverContext
                                },
                                stopInputBlock = {
                                    this.buildingId = bldId
                                }
                            )
                        )
                    }
                }

                val responseJson = JSON.encode(response)
                val resourceResponseJson = JSON.encode(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
            }

            SaveDataMethod.BUILDING_UPGRADE_BUY -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_UPGRADE_BUY' message for $saveId and $bldId" }

                val svcPlayer = serverContext.requirePlayerContext(playerId).services
                val building = svc.getBuilding(bldId) ?: run {
                    Logger.error(LogConfigSocketError) { "Building bldId=$bldId not found for playerId=$playerId" }
                    return
                }

                val playerCash = svcPlayer.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                var newLevel = 0
                var xpEarned = 0
                var upgradeCost = 0

                // Calculate cost before upgrade
                val buildingDef = GameDefinition.findBuilding(building.type)
                newLevel = building.level + 1
                upgradeCost = calculateBuildingCost(buildingDef, newLevel)

                var resourceResponse: GameResources? = null
                val response: BuildingUpgradeResponse

                if (playerCash < upgradeCost) {
                    response = BuildingUpgradeResponse(
                        success = false,
                        error = notEnoughCoinsErrorId,
                        items = emptyMap(),
                        timer = null,
                        cost = upgradeCost
                    )
                    Logger.warn(LogConfigSocketToClient) { "Not enough cash for instant building upgrade: required=$upgradeCost, available=$playerCash" }
                } else {
                    val result = svc.updateBuilding(bldId) { bld ->
                        val levelDef = buildingDef?.getLevel(newLevel)
                        xpEarned = levelDef?.xp ?: 50
                        bld.copy(level = newLevel, upgrade = null)
                    }

                    if (result.isSuccess) {
                        // Deduct cash
                        val updateResourceResult = svcPlayer.compound.updateResource { resource ->
                            resourceResponse = resource.copy(cash = playerCash - upgradeCost)
                            resourceResponse
                        }

                        if (updateResourceResult.isFailure) {
                            Logger.error(LogConfigSocketError) { "Failed to deduct cash for instant upgrade playerId=$playerId: ${updateResourceResult.exceptionOrNull()?.message}" }
                            response = BuildingUpgradeResponse(
                                success = false,
                                error = "",
                                items = emptyMap(),
                                timer = null
                            )
                        } else {
                            // Grant XP to player leader for instant upgrade purchase using centralized service
                            if (xpEarned > 0) {
                                try {
                                    val leader = svcPlayer.survivor.getSurvivorLeader()
                                    val playerObjects = serverContext.db.loadPlayerObjects(playerId)

                                    if (playerObjects != null) {
                                        // Use centralized XP service for consistent level calculation and rested XP bonus
                                        val (updatedLeader, updatedPlayerObjects) = XpLevelService.addXpToLeader(
                                            survivor = leader,
                                            playerObjects = playerObjects,
                                            earnedXp = xpEarned
                                        )

                                        val oldLevel = leader.level
                                        val newLevel = updatedLeader.level
                                        val newLevelPts = (newLevel - oldLevel).coerceAtLeast(0)

                                        // Update survivor in database
                                        svcPlayer.survivor.updateSurvivor(leader.id) { _ ->
                                            updatedLeader
                                        }

                                        // Update PlayerObjects with new levelPts and consumed restXP
                                        serverContext.db.updatePlayerObjectsJson(playerId, updatedPlayerObjects)

                                        Logger.info(LogConfigSocketError) {
                                            "Granted $xpEarned XP to player leader for instant building upgrade (bldId=$bldId). " +
                                            "Level: $oldLevel->$newLevel, XP: ${leader.xp}->${updatedLeader.xp}"
                                        }

                                        // Broadcast level up if player leveled up
                                        if (newLevelPts > 0) {
                                            val playerProfile = serverContext.playerAccountRepository.getProfileOfPlayerId(playerId).getOrNull()
                                            val playerName = playerProfile?.displayName ?: playerId
                                            BroadcastService.broadcastUserLevel(playerName, newLevel)
                                        }
                                    } else {
                                        Logger.error(LogConfigSocketError) {
                                            "Failed to load PlayerObjects for instant upgrade XP grant playerId=$playerId"
                                        }
                                    }
                                } catch (e: Exception) {
                                    Logger.error(LogConfigSocketError) {
                                        "Failed to grant XP for instant upgrade playerId=$playerId: ${e.message}"
                                    }
                                }
                            }

                            response = BuildingUpgradeResponse(
                                success = true,
                                items = emptyMap(),
                                timer = null,
                                level = newLevel,
                                cost = upgradeCost
                            )
                            Logger.info(LogConfigSocketToClient) { "Instant building upgraded: bldId=$bldId, newLevel=$newLevel, cost=$upgradeCost" }
                        }
                    } else {
                        Logger.error(LogConfigSocketError) { "Failed to upgrade (buy) building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                        response = BuildingUpgradeResponse(success = false, items = emptyMap(), timer = null)
                    }
                }

                val responseJson = JSON.encode(response)
                val resourceResponseJson = JSON.encode(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
            }

            SaveDataMethod.BUILDING_REPAIR_BUY -> {
                val bldId = data["id"] as? String ?: return
                val level = data["level"] as? Int ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_REPAIR_BUY' message for bldId=$bldId, level=$level for playerId=$playerId" }

                val svcPlayer = serverContext.requirePlayerContext(playerId).services
                val playerCash = svcPlayer.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                val building = svc.getBuilding(bldId) ?: run {
                    Logger.error(LogConfigSocketError) { "BUILDING_REPAIR_BUY: Building bldId=$bldId not found for playerId=$playerId" }
                    return
                }

                // Calculate repair cost
                val buildingDef = GameDefinition.findBuilding(building.type)
                val repairCost = calculateBuildingRepairCost(buildingDef, level)

                var resourceResponse: GameResources? = null
                val response: BuildingRepairResponse

                if (playerCash < repairCost) {
                    Logger.warn(LogConfigSocketToClient) { "BUILDING_REPAIR_BUY: Not enough cash. Required=$repairCost, Available=$playerCash for playerId=$playerId" }
                    val errorResponse = mapOf("success" to "false", "error" to notEnoughCoinsErrorId)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(errorResponse))))
                    return
                }

                // Instant repair - just mark as not destroyed
                val updateBuildingResult = svc.updateBuilding(bldId) { bld ->
                    bld.copy(destroyed = false)
                }

                if (updateBuildingResult.isSuccess) {
                    // Deduct cash
                    val updateResourceResult = svcPlayer.compound.updateResource { resource ->
                        resourceResponse = resource.copy(cash = playerCash - repairCost)
                        resourceResponse
                    }

                    if (updateResourceResult.isFailure) {
                        Logger.error(LogConfigSocketError) { "BUILDING_REPAIR_BUY: Failed to deduct cash for playerId=$playerId: ${updateResourceResult.exceptionOrNull()?.message}" }
                        response = BuildingRepairResponse(success = false, items = emptyMap(), timer = null)
                    } else {
                        response = BuildingRepairResponse(success = true, items = emptyMap(), timer = null)
                        Logger.info(LogConfigSocketToClient) { "BUILDING_REPAIR_BUY: Building bldId=$bldId repaired instantly for cost=$repairCost" }
                    }
                } else {
                    Logger.error(LogConfigSocketError) { "BUILDING_REPAIR_BUY: Failed to repair building bldId=$bldId for playerId=$playerId: ${updateBuildingResult.exceptionOrNull()?.message}" }
                    response = BuildingRepairResponse(success = false, items = emptyMap(), timer = null)
                }

                val responseJson = JSON.encode(response)
                val resourceResponseJson = JSON.encode(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
            }

            SaveDataMethod.BUILDING_TRAP_EXPLODE -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_TRAP_EXPLODE' message for bldId=$bldId for playerId=$playerId" }

                // Delete the trap building (it explodes and is destroyed)
                val result = svc.deleteBuilding(bldId)

                val response = if (result.isSuccess) {
                    Logger.info(LogConfigSocketToClient) { "BUILDING_TRAP_EXPLODE: Trap bldId=$bldId exploded and removed for playerId=$playerId" }
                    mapOf("success" to true)
                } else {
                    Logger.error(LogConfigSocketError) { "BUILDING_TRAP_EXPLODE: Failed to remove trap bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    mapOf("success" to false)
                }

                send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(response))))
            }
        }
    }

    /**
     * DEPRECATED: Use XpLevelService.calculateLevelFromTotalXp instead
     * Calculates player level based on total XP using quadratic formula.
     * XP required for each level: 100 * (level+1)²
     * This matches the client formula: LEVEL_XP_MULTIPLIER * (level+1)² * BASE_XP_MULTIPLIER = 100 * (level+1)² * 1
     */
    @Deprecated("Use XpLevelService.calculateLevelFromTotalXp instead", ReplaceWith("XpLevelService.calculateLevelFromTotalXp(currentLevel, currentXp, totalXp).first"))
    private fun calculateLevel(totalXp: Int): Int {
        // This function is deprecated but kept for backward compatibility
        // It assumes currentLevel=0, currentXp=0 and calculates level from total XP
        return XpLevelService.calculateLevelFromTotalXp(0, 0, totalXp).first
    }

    /**
     * Calculates instant purchase cost for building construction or upgrade.
     * Based on AS3 client formula: totalResCost * coinsPerResUnit + buildTime * coinsPerSecond
     *
     * Constants from AS3 client (constructionCosts in CostTable):
     * - coinsPerResUnit: Cost multiplier per resource unit
     * - coinsPerSecond: Cost multiplier per second of build time
     */
    private fun calculateBuildingCost(buildingDef: BuildingResource?, level: Int): Int {
        if (buildingDef == null) return 100 // Default fallback cost

        val levelDef = buildingDef.getLevel(level) ?: return 100

        // Constants from AS3 client (can be adjusted)
        val coinsPerResUnit = 1.0  // Cost per resource unit
        val coinsPerSecond = 0.5   // Cost per second of build time

        // Calculate total resource cost based on building resources and level
        var totalResCost = 0.0
        
        // Get base resources from building definition
        val resources = buildingDef.resources
        if (resources != null) {
            val multiplier = buildingDef.resourceMultiplier
            val baseCost = (resources.wood + resources.metal + resources.cloth + 
                           resources.food + resources.water + resources.ammunition + resources.cash).toDouble()
            
            // Apply multiplier for each level
            var levelCost = baseCost
            for (i in 0 until level) {
                levelCost = kotlin.math.floor(levelCost * multiplier)
            }
            
            // Round to nearest 5 (as per client code line 324)
            totalResCost = kotlin.math.floor(kotlin.math.floor(levelCost / 5) * 5)
        }
        
        // Add any specific level requirements (items or resources)
        levelDef.requirements?.items?.forEach { itemReq ->
            totalResCost += itemReq.quantity
        }

        // Get build time in seconds
        val buildTime = levelDef.time ?: 1

        // Calculate final cost: resources cost + time cost
        val cost = (totalResCost * coinsPerResUnit + buildTime * coinsPerSecond).toInt()

        // Ensure minimum cost of 1 (matches AS3 client behavior)
        return maxOf(cost, 1)
    }

    /**
     * Calculates instant purchase cost for building repair.
     * Based on similar formula as building construction cost.
     */
    private fun calculateBuildingRepairCost(buildingDef: BuildingResource?, level: Int): Int {
        if (buildingDef == null) return 50 // Default fallback cost

        val levelDef = buildingDef.getLevel(level) ?: return 50

        // Constants for repair (typically lower than construction)
        val coinsPerResUnit = 0.5  // Cost per resource unit for repair
        val coinsPerSecond = 0.25  // Cost per second of repair time

        // Calculate total resource cost (half of construction cost as per client code line 399)
        var totalResCost = 0.0
        
        // Get base resources from building definition
        val resources = buildingDef.resources
        if (resources != null) {
            val multiplier = buildingDef.resourceMultiplier
            val baseCost = (resources.wood + resources.metal + resources.cloth + 
                           resources.food + resources.water + resources.ammunition + resources.cash).toDouble()
            
            // Apply multiplier for each level
            var levelCost = baseCost
            for (i in 0 until level) {
                levelCost = kotlin.math.floor(levelCost * multiplier)
            }
            
            // Round to nearest 5
            levelCost = kotlin.math.floor(kotlin.math.floor(levelCost / 5) * 5)
            
            // Apply repair cost multiplier (50% of construction cost)
            totalResCost = kotlin.math.floor(levelCost * 0.5)
        }
        
        // Add any specific level requirements
        levelDef.requirements?.items?.forEach { itemReq ->
            totalResCost += itemReq.quantity * 0.5
        }

        // Get repair time in seconds (same as build time)
        val repairTime = levelDef.time ?: 1

        // Calculate final cost: resources cost + time cost
        val cost = (totalResCost * coinsPerResUnit + repairTime * coinsPerSecond).toInt()

        // Ensure minimum cost of 1
        return maxOf(cost, 1)
    }
}