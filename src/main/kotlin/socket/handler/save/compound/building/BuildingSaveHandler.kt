package dev.deadzone.socket.handler.save.compound.building

import dev.deadzone.context.GlobalContext
import dev.deadzone.context.ServerContext
import dev.deadzone.context.requirePlayerContext
import dev.deadzone.core.model.game.data.*
import dev.deadzone.socket.core.Connection
import dev.deadzone.socket.handler.buildMsg
import dev.deadzone.socket.handler.save.SaveSubHandler
import dev.deadzone.socket.handler.save.compound.building.response.*
import dev.deadzone.socket.messaging.NetworkMessage
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.socket.protocol.PIOSerializer
import dev.deadzone.socket.tasks.TaskTemplate
import dev.deadzone.utils.LogConfigSocketError
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger
import kotlin.math.max
import kotlin.time.Duration.Companion.minutes
import kotlin.time.Duration.Companion.seconds

class BuildingSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.COMPOUND_BUILDING_SAVES

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        val playerId = connection.playerId
        val svc = serverContext.requirePlayerContext(playerId).services.compound

        when (type) {
            SaveDataMethod.BUILDING_CREATE -> {
                val bldId = data["id"] as? String ?: return
                val bldType = data["type"] as? String ?: return
                val x = data["tx"] as? Int ?: return
                val y = data["ty"] as? Int ?: return
                val r = data["rotation"] as? Int ?: return
                Logger.debug(LogConfigSocketToClient) { "'BUILDING_CREATE' message for $saveId and $bldId,$bldType to tx=$x, ty=$y, rotation=$r" }

                val buildDuration = if (bldType.contains("storage")) 1.minutes else 4.seconds
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

                val response = if (result.isSuccess) {
                    BuildingCreateResponse(
                        success = true,
                        items = emptyMap(),
                        timer = timer
                    )
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to create building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    BuildingCreateResponse(
                        success = false,
                        items = emptyMap(),
                        timer = null
                    )
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTask(
                        connection = connection,
                        taskTemplateKey = TaskTemplate.BUILDING,
                        cfgBuilder = {
                            it.copy(
                                targetTask = NetworkMessage.BUILDING_COMPLETE,
                                initialRunDelay = buildDuration,
                                extra = mapOf("msg" to listOf(bldId))
                            )
                        },
                        onComplete = {}
                    )
                }
            }

            SaveDataMethod.BUILDING_MOVE -> {
                val x = (data["tx"] as? Number)?.toInt() ?: return
                val y = (data["ty"] as? Number)?.toInt() ?: return
                val r = (data["rotation"] as? Number)?.toInt() ?: return
                val buildingId = data["id"] as? String ?: return
                Logger.debug(LogConfigSocketToClient) { "'bld_move' message for $saveId and $buildingId to tx=$x, ty=$y, rotation=$r" }

                val result = svc.updateBuilding(buildingId) { it.copy(tx = x, ty = y, rotation = r) }
                val response = if (result.isSuccess) {
                    BuildingMoveResponse(success = true, x = x, y = y, r = r)
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to move building bldId=$buildingId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    BuildingMoveResponse(success = false, x = x, y = y, r = r)
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_UPGRADE -> {
                val bldId = data["id"] as? String ?: return
                Logger.debug(LogConfigSocketToClient) { "'BUILDING_UPGRADE' message for $saveId and $bldId" }

                val buildDuration = 10.seconds
                lateinit var timer: TimerData
                val result = svc.updateBuilding(bldId) { bld ->
                    timer = TimerData.runForDuration(
                        duration = buildDuration,
                        data = mapOf("level" to (bld.level + 1), "type" to "upgrade", "xp" to 50)
                    )
                    bld.copy(upgrade = timer)
                }

                val response = if (result.isSuccess) {
                    BuildingUpgradeResponse(success = true, items = emptyMap(), timer = timer)
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to upgrade building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    BuildingUpgradeResponse(success = false, items = emptyMap(), timer = null)
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTask(
                        connection = connection,
                        taskTemplateKey = TaskTemplate.BUILDING,
                        cfgBuilder = {
                            it.copy(
                                targetTask = NetworkMessage.BUILDING_COMPLETE,
                                initialRunDelay = buildDuration,
                                extra = mapOf("msg" to listOf(bldId))
                            )
                        },
                        onComplete = {}
                    )
                }
            }

            SaveDataMethod.BUILDING_RECYCLE -> {
                val bldId = data["id"] as? String ?: return
                Logger.debug(LogConfigSocketToClient) { "'BUILDING_RECYCLE' message for $saveId and $bldId" }

                val result = svc.deleteBuilding(bldId)
                val response = if (result.isSuccess) {
                    BuildingRecycleResponse(success = true, items = emptyMap())
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to recycle building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    BuildingRecycleResponse(success = false, items = emptyMap())
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_COLLECT -> {
                val bldId = data["id"] as? String ?: return
                Logger.debug(LogConfigSocketToClient) { "'BUILDING_COLLECT' message for $saveId and $bldId" }

                val collectResult = svc.collectBuilding(bldId)
                val response = if (collectResult.isSuccess) {
                    val res = collectResult.getOrThrow()
                    val resType = requireNotNull(res.getNonEmptyResTypeOrNull()) { "Unexpected null on getNonEmptyResTypeOrNull during collect resource" }
                    val resAmount = requireNotNull(res.getNonEmptyResAmountOrNull()?.toDouble()) { "Unexpected null on getNonEmptyResAmountOrNull during collect resource" }
                    val currentResource = svc.getResources()
                    val limit = 100.0 // TODO: Base this on storage capacity from GameDefinitions
                    val expectedResource = currentResource.wood + resAmount
                    val remainder = expectedResource - limit
                    val total = max(limit, expectedResource)
                    BuildingCollectResponse(
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
                    BuildingCollectResponse(
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
                Logger.debug(LogConfigSocketToClient) { "'BUILDING_CANCEL' message for $saveId and $bldId" }

                val result = runCatching { svc.cancelBuilding(bldId) }
                val response = if (result.isSuccess) {
                    BuildingCancelResponse(success = true, items = emptyMap())
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to cancel building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    BuildingCancelResponse(success = false, items = emptyMap())
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_SPEED_UP -> {
                val bldId = data["id"] as? String ?: return
                Logger.debug(LogConfigSocketToClient) { "'BUILDING_SPEED_UP' message for $saveId and $bldId" }

                val result = svc.updateBuilding(bldId) { bld -> bld.copy(upgrade = null) }
                val response = if (result.isSuccess) {
                    BuildingSpeedUpResponse(success = true, error = "", cost = 0)
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to speed up building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    BuildingSpeedUpResponse(success = false, error = result.exceptionOrNull()?.message ?: "Unknown error", cost = 0)
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_REPAIR -> {
                val bldId = data["id"] as? String ?: return
                Logger.debug(LogConfigSocketToClient) { "'BUILDING_REPAIR' message for $saveId and $bldId" }

                val buildDuration = 10.seconds
                val timer = TimerData.runForDuration(
                    duration = buildDuration,
                    data = mapOf("type" to "repair")
                )

                val result = svc.updateBuilding(bldId) { bld -> bld.copy(repair = timer) }
                val response = if (result.isSuccess) {
                    BuildingRepairResponse(success = true, items = emptyMap(), timer = timer)
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to repair building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    BuildingRepairResponse(success = false, items = emptyMap(), timer = null)
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTask(
                        connection = connection,
                        taskTemplateKey = TaskTemplate.BUILDING,
                        cfgBuilder = {
                            it.copy(
                                targetTask = NetworkMessage.BUILDING_REPAIR_COMPLETE,
                                initialRunDelay = buildDuration,
                                extra = mapOf("msg" to listOf(bldId))
                            )
                        },
                        onComplete = {}
                    )
                }
            }

            SaveDataMethod.BUILDING_REPAIR_SPEED_UP -> {
                val bldId = data["id"] as? String ?: return
                Logger.debug(LogConfigSocketToClient) { "'BUILDING_REPAIR_SPEED_UP' message for $saveId and $bldId" }

                val result = svc.updateBuilding(bldId) { bld -> bld.copy(repair = null) }
                val response = if (result.isSuccess) {
                    BuildingSpeedUpResponse(success = true, error = "", cost = 0)
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to speed up repair for building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    BuildingSpeedUpResponse(success = false, error = result.exceptionOrNull()?.message ?: "Unknown error", cost = 0)
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_CREATE_BUY -> {
                val bldId = data["id"] as? String ?: return
                val bldType = data["type"] as? String ?: return
                val x = data["tx"] as? Int ?: return
                val y = data["ty"] as? Int ?: return
                val r = data["rotation"] as? Int ?: return
                Logger.debug(LogConfigSocketToClient) { "'BUILDING_CREATE_BUY' message for $saveId and $bldId,$bldType to tx=$x, ty=$y, rotation=$r" }

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

                val response = if (result.isSuccess) {
                    BuildingCreateResponse(
                        success = true,
                        items = emptyMap(),
                        timer = timer
                    )
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to create (buy) building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    BuildingCreateResponse(
                        success = false,
                        items = emptyMap(),
                        timer = null
                    )
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTask(
                        connection = connection,
                        taskTemplateKey = TaskTemplate.BUILDING,
                        cfgBuilder = {
                            it.copy(
                                targetTask = NetworkMessage.BUILDING_COMPLETE,
                                initialRunDelay = buildDuration,
                                extra = mapOf("msg" to listOf(bldId))
                            )
                        },
                        onComplete = {}
                    )
                }
            }

            SaveDataMethod.BUILDING_UPGRADE_BUY -> {
                val bldId = data["id"] as? String ?: return
                Logger.debug(LogConfigSocketToClient) { "'BUILDING_UPGRADE_BUY' message for $saveId and $bldId" }

                val buildDuration = 0.seconds
                lateinit var timer: TimerData
                val result = svc.updateBuilding(bldId) { bld ->
                    timer = TimerData.runForDuration(
                        duration = buildDuration,
                        data = mapOf("level" to (bld.level + 1), "type" to "upgrade", "xp" to 50)
                    )
                    bld.copy(upgrade = timer)
                }

                val response = if (result.isSuccess) {
                    BuildingUpgradeResponse(success = true, items = emptyMap(), timer = timer)
                } else {
                    Logger.error(LogConfigSocketError) { "Failed to upgrade (buy) building bldId=$bldId for playerId=$playerId: ${result.exceptionOrNull()?.message}" }
                    BuildingUpgradeResponse(success = false, items = emptyMap(), timer = null)
                }

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (result.isSuccess) {
                    serverContext.taskDispatcher.runTask(
                        connection = connection,
                        taskTemplateKey = TaskTemplate.BUILDING,
                        cfgBuilder = {
                            it.copy(
                                targetTask = NetworkMessage.BUILDING_COMPLETE,
                                initialRunDelay = buildDuration,
                                extra = mapOf("msg" to listOf(bldId))
                            )
                        },
                        onComplete = {}
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