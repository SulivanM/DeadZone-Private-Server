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
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger
import kotlin.math.max
import kotlin.time.Duration.Companion.minutes
import kotlin.time.Duration.Companion.seconds

/**
 * Note about building operation:
 *
 * When building is created/upgraded/repaired:
 * - Client send the request
 * - Server reads that, create a building internally, with the upgrade/repair timer
 * - Timer data depends on operation, it usually includes type (e.g., "repair"/"upgrade"), level, xp
 * - Server should run a background task which fire when the building operation has finished
 * - The completion of that task should send a BUILDING_COMPLETE or BUILDING_REPAIR_COMPLETE message to client
 *
 * When user logoff whilst building operation is ongoing:
 * - Server do not need to save anything, assuming that server already saves everything on operation start.
 *
 * When user login whilst building operation is still on going:
 * - Server does not need to update the upgrade/repair timer, this is because clients read it.
 * - Instead, when the timer has ended, schedule a background task that sends
 * BUILDING_COMPLETE after game is started (which is after INIT_COMPLETE)
 * - The game automatically read the timer and start their countdown of the task.
 *
 * When user login after building operation is done:
 * - Same, no need to update timer. Don't delete it because client reads it.
 * - No need to send BUILDING_COMPLETE, (NOTSURE): but you will likely need to reflect the building operation, maybe during PlayerLoginState?
 */
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

        when (type) {
            // read buildings.xml from GameDefinition for items/build duration
            SaveDataMethod.BUILDING_CREATE -> {
                val bldId = data["id"] as String? ?: return
                val bldType = data["type"] as String? ?: return
                val x = data["tx"] as Int? ?: return
                val y = data["ty"] as Int? ?: return
                val r = data["rotation"] as Int? ?: return

                Logger.debug(LogConfigSocketToClient) { "'BUILDING_CREATE' message for $saveId and $bldId,$bldType to tx=$x, ty=$y, rotation=$r" }

                val buildDuration = if (bldType.contains("storage")) 1.minutes else 4.seconds

                val timer = TimerData.runForDuration(
                    duration = buildDuration,
                    // xp used when reconnect, readObject of building
                    data = mapOf("level" to 0, "type" to "upgrade", "xp" to 50)
                )

                val svc = serverContext.requirePlayerContext(playerId).services
                svc.compound.createBuilding {
                    Building(
                        id = bldId,
                        name = null,
                        type = bldType,
                        level = 0, // always 0 because create
                        rotation = r,
                        tx = x,
                        ty = y,
                        destroyed = false,
                        resourceValue = 0.0,
                        upgrade = timer, // create can be thought as an upgrade to level 0
                        repair = null
                    )
                }

                val response = BuildingCreateResponse(
                    // although client know user's resource,
                    // server may revalidate (in-case user did client-side hacking)
                    success = true,
                    items = emptyMap(),
                    timer = timer
                )

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

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

            SaveDataMethod.BUILDING_MOVE -> {
                val x = (data["tx"] as? Number)?.toInt() ?: return
                val y = (data["ty"] as? Number)?.toInt() ?: return
                val r = (data["rotation"] as? Number)?.toInt() ?: return
                val buildingId = data["id"] as String? ?: return

                Logger.debug(LogConfigSocketToClient) { "'bld_move' message for $saveId and $buildingId to tx=$x, ty=$y, rotation=$r" }

                val svc = serverContext.requirePlayerContext(playerId).services
                svc.compound.updateBuilding(buildingId) {
                    it.copy(tx = x, ty = y, rotation = r)
                }

                val responseJson = GlobalContext.json.encodeToString(
                    BuildingMoveResponse(
                        success = true, x = x, y = y, r = r
                    )
                )

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_UPGRADE -> {
                val bldId = data["id"] as String? ?: return

                Logger.debug(LogConfigSocketToClient) { "'BUILDING_UPGRADE' message for $saveId and $bldId" }

                val buildDuration = 10.seconds

                lateinit var timer: TimerData
                val svc = serverContext.requirePlayerContext(playerId).services
                svc.compound.updateBuilding(bldId) { bld ->
                    timer = TimerData.runForDuration(
                        duration = buildDuration,
                        data = mapOf("level" to (bld.level + 1), "type" to "upgrade", "xp" to 50)
                    )
                    bld.copy(upgrade = timer)
                }

                val response = BuildingUpgradeResponse(
                    success = true,
                    items = emptyMap(),
                    timer = timer
                )

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

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

            SaveDataMethod.BUILDING_RECYCLE -> {
                val bldId = data["id"] as String? ?: return

                Logger.debug(LogConfigSocketToClient) { "'BUILDING_RECYCLE' message for $saveId and $bldId" }

                val svc = serverContext.requirePlayerContext(playerId).services
                svc.compound.deleteBuilding(bldId)

                val response = BuildingRecycleResponse(
                    success = true,
                    items = emptyMap(),
                )

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_COLLECT -> {
                val bldId = data["id"] as String? ?: return

                Logger.debug(LogConfigSocketToClient) { "'BUILDING_COLLECT' message for $saveId and $bldId" }

                val svc = serverContext.requirePlayerContext(playerId).services
                val collectResult = svc.compound.collectBuilding(bldId)
                val resType =
                    requireNotNull(collectResult.getNonEmptyResTypeOrNull()) { "Unexpected null on getNonEmptyResTypeOrNull during collect resource" }
                val resAmount =
                    requireNotNull(
                        collectResult.getNonEmptyResAmountOrNull()?.toDouble()
                    ) { "Unexpected null on getNonEmptyResAmountOrNull during collect resource" }

                val currentResource = svc.compound.getResources()
                val limit = 100.0 // this based on storage
                val expectedResource = currentResource.wood + resAmount
                val remainder = expectedResource - limit
                val total = max(limit, expectedResource)

                val response = BuildingCollectResponse(
                    success = true,
                    locked = false,
                    resource = resType,
                    collected = resAmount,
                    remainder = remainder, // - with current resource
                    total = total, // + with current resource
                    bonus = 0.0,
                    destroyed = false,
                )

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_CANCEL -> {
                val bldId = data["id"] as String? ?: return

                Logger.debug(LogConfigSocketToClient) { "'BUILDING_CANCEL' message for $saveId and $bldId" }

                val svc = serverContext.requirePlayerContext(playerId).services
                svc.compound.cancelBuilding(bldId)

                val response = BuildingCancelResponse(
                    success = true,
                    items = emptyMap(),
                )

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_SPEED_UP -> {
                val bldId = data["id"] as String? ?: return

                Logger.debug(LogConfigSocketToClient) { "'BUILDING_SPEED_UP' message for $saveId and $bldId" }

                val svc = serverContext.requirePlayerContext(playerId).services
                svc.compound.updateBuilding(bldId) { bld ->
                    bld.copy(upgrade = null)
                }

                val response = BuildingSpeedUpResponse(
                    success = true,
                    error = "",
                    cost = 0
                )

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_REPAIR -> {
                val bldId = data["id"] as String? ?: return

                Logger.debug(LogConfigSocketToClient) { "'BUILDING_REPAIR' message for $saveId and $bldId" }

                val buildDuration = 10.seconds
                val timer = TimerData.runForDuration(
                    duration = buildDuration,
                    data = mapOf("type" to "repair")
                )

                val svc = serverContext.requirePlayerContext(playerId).services
                svc.compound.updateBuilding(bldId) { bld ->
                    bld.copy(repair = timer)
                }

                val response = BuildingRepairResponse(
                    success = true,
                    items = emptyMap(),
                    timer = timer
                )

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

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

            SaveDataMethod.BUILDING_REPAIR_SPEED_UP -> {
                val bldId = data["id"] as String? ?: return

                Logger.debug(LogConfigSocketToClient) { "'BUILDING_REPAIR_SPEED_UP' message for $saveId and $bldId" }

                val svc = serverContext.requirePlayerContext(playerId).services
                svc.compound.updateBuilding(bldId) { bld ->
                    bld.copy(repair = null)
                }

                val response = BuildingSpeedUpResponse(
                    success = true,
                    error = "",
                    cost = 0
                )

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.BUILDING_CREATE_BUY -> {
                val bldId = data["id"] as String? ?: return
                val bldType = data["type"] as String? ?: return
                val x = data["tx"] as Int? ?: return
                val y = data["ty"] as Int? ?: return
                val r = data["rotation"] as Int? ?: return

                Logger.debug(LogConfigSocketToClient) { "'BUILDING_CREATE_BUY' message for $saveId and $bldId,$bldType to tx=$x, ty=$y, rotation=$r" }

                val buildDuration = 0.seconds

                val timer = TimerData.runForDuration(
                    duration = buildDuration,
                    // xp used when reconnect, readObject of building
                    data = mapOf("level" to 0, "type" to "upgrade", "xp" to 50)
                )

                val svc = serverContext.requirePlayerContext(playerId).services
                svc.compound.createBuilding {
                    Building(
                        id = bldId,
                        name = null,
                        type = bldType,
                        level = 0, // always 0 because create
                        rotation = r,
                        tx = x,
                        ty = y,
                        destroyed = false,
                        resourceValue = 0.0,
                        upgrade = timer, // create can be thought as an upgrade to level 0
                        repair = null
                    )
                }

                val response = BuildingCreateResponse(
                    // although client know user's resource,
                    // server may revalidate (in-case user did client-side hacking)
                    success = true,
                    items = emptyMap(),
                    timer = timer
                )

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

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

            SaveDataMethod.BUILDING_UPGRADE_BUY -> {
                val bldId = data["id"] as String? ?: return

                Logger.debug(LogConfigSocketToClient) { "'BUILDING_UPGRADE_BUY' message for $saveId and $bldId" }

                val buildDuration = 0.seconds

                lateinit var timer: TimerData
                val svc = serverContext.requirePlayerContext(playerId).services
                svc.compound.updateBuilding(bldId) { bld ->
                    timer = TimerData.runForDuration(
                        duration = buildDuration,
                        data = mapOf("level" to (bld.level + 1), "type" to "upgrade", "xp" to 50)
                    )
                    bld.copy(upgrade = timer)
                }

                val response = BuildingUpgradeResponse(
                    success = true,
                    items = emptyMap(),
                    timer = timer
                )

                val responseJson = GlobalContext.json.encodeToString(response)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

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

            SaveDataMethod.BUILDING_REPAIR_BUY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BUILDING_REPAIR_BUY' message [not implemented]" }
            }

            SaveDataMethod.BUILDING_TRAP_EXPLODE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'BUILDING_TRAP_EXPLODE' message [not implemented]" }
            }
        }
    }
}
