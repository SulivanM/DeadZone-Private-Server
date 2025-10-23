package server.handler.save.compound.building

import context.GlobalContext
import context.requirePlayerContext
import core.model.game.data.*
import dev.deadzone.core.model.game.data.TimerData
import dev.deadzone.core.model.game.data.reduceBy
import dev.deadzone.core.model.game.data.reduceByHalf
import dev.deadzone.core.model.game.data.removeIfFinished
import dev.deadzone.core.model.game.data.secondsLeftToEnd
import dev.deadzone.socket.handler.save.SaveHandlerContext
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
import utils.LogConfigSocketError
import utils.LogConfigSocketToClient
import utils.Logger
import kotlin.math.max
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

                val buildDuration = 1444.seconds
                val timer = TimerData.runForDuration(
                    duration = buildDuration,
                    data = mapOf("level" to 0, "type" to "upgrade", "xp" to 50)
                )

                val result = runCatching {
                    svc.createBuilding {
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

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = BuildingCreateTask(
                            taskInputBlock = {
                                this.buildingId = bldId
                                this.buildDuration = buildDuration
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

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_UPGRADE -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_UPGRADE' message for $saveId and $bldId" }

                val buildDuration = 10.seconds
                lateinit var timer: TimerData
                val result = svc.updateBuilding(bldId) { bld ->
                    timer = TimerData.runForDuration(
                        duration = buildDuration,
                        data = mapOf("level" to (bld.level + 1), "type" to "upgrade", "xp" to 50)
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

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = BuildingCreateTask(
                            taskInputBlock = {
                                this.buildingId = bldId
                                this.buildDuration = buildDuration
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

                val responseJson = GlobalContext.json.encodeToString(response)
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
                    val limit = 100.0 // TODO: Base this on storage capacity from GameDefinitions
                    val expectedResource = currentResource.wood + resAmount
                    val remainder = expectedResource - limit
                    val total = max(limit, expectedResource)
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

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_CANCEL -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_CANCEL' message for $saveId and $bldId" }

                val result = runCatching { svc.cancelBuilding(bldId) }

                val response: BuildingCancelResponse
                if (result.isSuccess) {
                    response = BuildingCancelResponse(success = true, items = emptyMap())
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to cancel building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    response = BuildingCancelResponse(success = false, items = emptyMap())
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_SPEED_UP -> {
                val bldId = data["id"] as? String ?: return
                val option = data["option"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_SPEED_UP' message for bldId=$bldId with option.key=$option" }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val playerFuel = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                val response: BuildingSpeedUpResponse
                var resourceResponse: GameResources? = null
                if (playerFuel < 0) {
                    response = BuildingSpeedUpResponse(error = notEnoughCoinsErrorId, success = false, cost = 0)
                } else {
                    val building =
                        requireNotNull(svc.compound.getBuilding(bldId)) { "Building bldId=$bldId was somehow null in BUILDING_SPEED_UP request for playerId=$playerId" }.toBuilding()
                    val upgradeTimer =
                        requireNotNull(building.upgrade) { "Building upgrade timer for bldId=$bldId was somehow null in BUILDING_SPEED_UP request for playerId=$playerId" }

                    // TO-DO ensure that the selected option is enabled in the cost table.
                    // this prevent player from manipulating packet to unknown speed up option
                    // TO-DO: calculate the cost in cost table
                    val (newBuilding, cost) = when (option) {
                        "SpeedUpOneHour" -> {
                            building.copy(upgrade = upgradeTimer.reduceBy(1.hours)) to 1
                        }

                        "SpeedUpTwoHour" -> {
                            building.copy(upgrade = upgradeTimer.reduceBy(2.hours)) to 1
                        }

                        "SpeedUpHalf" -> {
                            building.copy(upgrade = upgradeTimer.reduceByHalf()) to 1
                        }

                        "SpeedUpComplete" -> {
                            building.copy(upgrade = null) to 1
                        }

                        "SpeedUpFree" -> {
                            // TO-DO lookup cost table and see the minimum time to speed up for free
                            // in this case, only if building duration is less than 5 minutes it will be allowed
                            if (building.upgrade.secondsLeftToEnd() <= 300) {
                                building.copy(upgrade = null) to 1
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
                        // successful response
                        svc.compound.updateBuilding(bldId) { newBuilding as BuildingLike }
                        svc.compound.updateResource { resource ->
                            resourceResponse = resource.copy(cash = playerFuel - cost)
                            resourceResponse
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
                                },
                                stopInputBlock = {
                                    this.buildingId = bldId
                                }
                            )
                        )

                        response = BuildingSpeedUpResponse(error = "", success = true, cost = cost)
                    } else {
                        // unexpected DB error response
                        Logger.error(LogConfigSocketError) { "Failed to speed up create building bldId=$bldId for playerId=$playerId: old=${building.toCompactString()} new=${newBuilding?.toCompactString()}" }
                        response = BuildingSpeedUpResponse(error = "", success = false, cost = 1)
                    }
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                val resourceResponseJson = GlobalContext.json.encodeToString(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
            }

            SaveDataMethod.BUILDING_REPAIR -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_REPAIR' message for $saveId and $bldId" }

                val buildDuration = 10.seconds
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

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = BuildingRepairTask(
                            taskInputBlock = {
                                this.buildingId = bldId
                                this.repairDuration = buildDuration
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

                var resourceResponse: GameResources? = null
                val response: BuildingRepairSpeedUpResponse
                if (playerFuel < 0) {
                    response = BuildingRepairSpeedUpResponse(error = notEnoughCoinsErrorId, success = false, cost = 0)
                } else {
                    val building =
                        requireNotNull(svc.compound.getBuilding(bldId)) { "Building bldId=$bldId was somehow null in BUILDING_REPAIR_SPEED_UP request for playerId=$playerId" }.toBuilding()
                    val repairTimer =
                        requireNotNull(building.repair) { "Building repair timer for bldId=$bldId was somehow null in BUILDING_REPAIR_SPEED_UP request for playerId=$playerId" }

                    // TO-DO ensure that the selected option is enabled in the cost table.
                    // this prevent player from manipulating packet to unknown speed up option
                    // TO-DO: calculate the cost in cost table
                    val (newBuilding, cost) = when (option) {
                        "SpeedUpOneHour" -> {
                            building.copy(repair = repairTimer.reduceBy(1.hours)) to 1
                        }

                        "SpeedUpTwoHour" -> {
                            building.copy(repair = repairTimer.reduceBy(2.hours)) to 1
                        }

                        "SpeedUpHalf" -> {
                            building.copy(repair = repairTimer.reduceByHalf()) to 1
                        }

                        "SpeedUpComplete" -> {
                            building.copy(repair = null) to 1
                        }

                        "SpeedUpFree" -> {
                            // TO-DO lookup cost table and see the minimum time to speed up for free
                            // in this case, only if building duration is less than 5 minutes it will be allowed
                            if (building.repair.secondsLeftToEnd() <= 300) {
                                building.copy(repair = null) to 1
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
                        // successful response
                        svc.compound.updateBuilding(bldId) { newBuilding as BuildingLike }
                        svc.compound.updateResource { resource ->
                            resourceResponse = resource.copy(cash = playerFuel - cost)
                            resourceResponse
                        }

                        response = BuildingRepairSpeedUpResponse(error = "", success = true, cost = cost)

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
                                },
                                stopInputBlock = {
                                    this.buildingId = bldId
                                }
                            )
                        )
                    } else {
                        // unexpected DB error response
                        Logger.error(LogConfigSocketError) { "Failed to speed up repair building bldId=$bldId for playerId=$playerId: old=${building.toCompactString()} new=${newBuilding?.toCompactString()}" }
                        response = BuildingRepairSpeedUpResponse(error = "", success = false, cost = 1)
                    }
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                val resourceResponseJson = GlobalContext.json.encodeToString(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
            }

            SaveDataMethod.BUILDING_CREATE_BUY -> {
                val bldId = data["id"] as? String ?: return
                val bldType = data["type"] as? String ?: return
                val x = data["tx"] as? Int ?: return
                val y = data["ty"] as? Int ?: return
                val r = data["rotation"] as? Int ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_CREATE_BUY' message for $saveId and $bldId,$bldType to tx=$x, ty=$y, rotation=$r" }

                val buildDuration = 0.seconds
                val timer = TimerData.runForDuration(
                    duration = buildDuration,
                    data = mapOf("level" to 0, "type" to "upgrade", "xp" to 50)
                )

                val result = runCatching {
                    svc.createBuilding {
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
                }

                val response: BuildingCreateResponse
                if (result.isSuccess) {
                    response = BuildingCreateResponse(
                        success = true,
                        items = emptyMap(),
                        timer = timer
                    )
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to create (buy) building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    response = BuildingCreateResponse(
                        success = false,
                        items = emptyMap(),
                        timer = null
                    )
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = BuildingCreateTask(
                            taskInputBlock = {
                                this.buildingId = bldId
                                this.buildDuration = buildDuration
                            },
                            stopInputBlock = {
                                this.buildingId = bldId
                            }
                        )
                    )
                }
            }

            SaveDataMethod.BUILDING_UPGRADE_BUY -> {
                val bldId = data["id"] as? String ?: return
                Logger.info(LogConfigSocketToClient) { "'BUILDING_UPGRADE_BUY' message for $saveId and $bldId" }

                val buildDuration = 0.seconds
                lateinit var timer: TimerData
                val result = svc.updateBuilding(bldId) { bld ->
                    timer = TimerData.runForDuration(
                        duration = buildDuration,
                        data = mapOf("level" to (bld.level + 1), "type" to "upgrade", "xp" to 50)
                    )
                    bld.copy(upgrade = timer)
                }

                val response: BuildingUpgradeResponse
                if (result.isSuccess) {
                    response = BuildingUpgradeResponse(success = true, items = emptyMap(), timer = timer)
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to upgrade (buy) building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    response = BuildingUpgradeResponse(success = false, items = emptyMap(), timer = null)
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = BuildingCreateTask(
                            taskInputBlock = {
                                this.buildingId = bldId
                                this.buildDuration = buildDuration
                            },
                            stopInputBlock = {
                                this.buildingId = bldId
                            }
                        )
                    )
                }
            }

            SaveDataMethod.BUILDING_REPAIR_BUY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BUILDING_REPAIR_BUY' message [not implemented]" }
            }

            SaveDataMethod.BUILDING_TRAP_EXPLODE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BUILDING_TRAP_EXPLODE' message [not implemented]" }
            }
        }
    }
}
