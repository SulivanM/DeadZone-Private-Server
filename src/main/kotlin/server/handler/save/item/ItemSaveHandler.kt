package server.handler.save.item

import context.requirePlayerContext
import core.items.model.Item
import dev.deadzone.core.model.game.data.hasEnded
import dev.deadzone.core.model.game.data.reduceBy
import dev.deadzone.core.model.game.data.reduceByHalf
import dev.deadzone.core.model.game.data.secondsLeftToEnd
import server.handler.save.SaveHandlerContext
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.handler.save.item.response.ItemBatchRecycleSpeedUpResponse
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import common.JSON
import common.LogConfigSocketToClient
import common.Logger
import core.game.SpeedUpCostCalculator
import common.UUID
import kotlin.random.Random
import kotlin.time.Duration.Companion.hours
import kotlin.time.Duration.Companion.seconds

class ItemSaveHandler : SaveSubHandler {
    override val supportedTypes: Set<String> = SaveDataMethod.ITEM_SAVES

    private fun generateRecycleRewards(itemType: String): List<Item> {
        val rewards = mutableListOf<Item>()

        val baseRewards = mapOf(
            "wood" to 2..5,
            "metal" to 1..3,
            "cloth" to 1..4,
            "water" to 1..2
        )

        baseRewards.forEach { (type, range) ->
            if (Random.nextDouble() < 0.3) {
                val qty = Random.nextInt(range.first, range.last + 1).toUInt()
                rewards.add(Item(
                    id = UUID.new(),
                    type = type,
                    qty = qty,
                    new = true
                ))
            }
        }

        return rewards
    }

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.ITEM -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM' message [not implemented]" }
            }

            SaveDataMethod.ITEM_BUY -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_BUY' message [not implemented]" }
            }

            SaveDataMethod.ITEM_LIST -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_LIST' message [not implemented]" }
            }

            SaveDataMethod.ITEM_RECYCLE -> {
                val itemId = data["id"] as? String
                if (itemId == null) {
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false}""")))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_RECYCLE: missing 'id' parameter" }
                    return@with
                }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val inventory = svc.inventory.getInventory()
                val itemToRecycle = inventory.find { it.id == itemId }

                if (itemToRecycle == null) {
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false}""")))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_RECYCLE: item not found with id=$itemId" }
                    return@with
                }

                svc.inventory.updateInventory { items ->
                    items.filter { it.id != itemId }
                }

                val recycledItems = generateRecycleRewards(itemToRecycle.type)

                if (recycledItems.isNotEmpty()) {
                    svc.inventory.updateInventory { items ->
                        items + recycledItems
                    }
                }

                val responseJson = if (recycledItems.isNotEmpty()) {
                    val itemsJsonArray = recycledItems.joinToString(",") { item ->
                        """{"id":"${item.id}","type":"${item.type}","qty":${item.qty},"new":true}"""
                    }
                    """{"success":true,"qty":0,"items":[$itemsJsonArray]}"""
                } else {
                    """{"success":true,"qty":0}"""
                }

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                Logger.info(LogConfigSocketToClient) {
                    "Item recycled: id=$itemId, type=${itemToRecycle.type}, rewards=${recycledItems.size} items for player ${connection.playerId}"
                }
            }

            SaveDataMethod.ITEM_DISPOSE -> {
                val itemId = data["id"] as? String
                if (itemId == null) {
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false}""")))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_DISPOSE: missing 'id' parameter" }
                    return@with
                }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val inventory = svc.inventory.getInventory()
                val itemToDispose = inventory.find { it.id == itemId }

                if (itemToDispose == null) {
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false}""")))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_DISPOSE: item not found with id=$itemId" }
                    return@with
                }

                svc.inventory.updateInventory { items ->
                    items.filter { it.id != itemId }
                }

                send(PIOSerializer.serialize(buildMsg(saveId, """{"success":true,"qty":0}""")))

                Logger.info(LogConfigSocketToClient) { "Item disposed: id=$itemId, type=${itemToDispose.type}, qty=${itemToDispose.qty} for player ${connection.playerId}" }
            }

            SaveDataMethod.ITEM_CLEAR_NEW -> {
                val svc = serverContext.requirePlayerContext(connection.playerId).services

                svc.inventory.updateInventory { items ->
                    items.map { item -> item.copy(new = false) }
                }

                Logger.info(LogConfigSocketToClient) { "Cleared 'new' flag on all items for player ${connection.playerId}" }
            }

            SaveDataMethod.ITEM_BATCH_RECYCLE -> {
                val itemsMap = data["items"] as? Map<*, *>
                val buy = data["buy"] as? Boolean ?: false

                if (itemsMap == null) {
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false}""")))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_BATCH_RECYCLE: missing 'items' parameter" }
                    return@with
                }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val inventory = svc.inventory.getInventory()

                val itemsToRecycle = mutableListOf<core.items.model.Item>()
                val recycledOutputItems = mutableListOf<core.items.model.Item>()

                for ((itemIdStr, qtyObj) in itemsMap) {
                    val itemId = itemIdStr.toString()
                    val qty = (qtyObj as? Number)?.toInt() ?: 1

                    val itemInInventory = inventory.find { it.id.equals(itemId, ignoreCase = true) }
                    if (itemInInventory != null) {
                        val itemToAdd = itemInInventory.copy(qty = minOf(qty.toUInt(), itemInInventory.qty))
                        itemsToRecycle.add(itemToAdd)

                        val rewards = generateRecycleRewards(itemInInventory.type)
                        for (reward in rewards) {
                            val existingReward = recycledOutputItems.find { it.type == reward.type }
                            if (existingReward != null) {
                                val idx = recycledOutputItems.indexOf(existingReward)
                                recycledOutputItems[idx] = existingReward.copy(qty = existingReward.qty + (reward.qty * itemToAdd.qty))
                            } else {
                                recycledOutputItems.add(reward.copy(qty = reward.qty * itemToAdd.qty))
                            }
                        }
                    }
                }

                if (itemsToRecycle.isEmpty()) {
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false}""")))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_BATCH_RECYCLE: no valid items to recycle" }
                    return@with
                }

                val timePerItem = 10
                val timePerQty = 5
                val totalQty = recycledOutputItems.sumOf { it.qty.toInt() }
                val totalTime = itemsToRecycle.size * timePerItem + totalQty * timePerQty

                val minCost = 50
                val costPerMin = 0.5
                val cost = maxOf(minCost, (costPerMin * (totalTime / 60.0)).toInt())

                if (buy) {
                    val currentCash = svc.compound.getResources().cash
                    if (currentCash < cost) {
                        send(PIOSerializer.serialize(buildMsg(saveId, """{"success":false,"error":"55"}""")))
                        Logger.warn(LogConfigSocketToClient) { "ITEM_BATCH_RECYCLE: not enough cash for player ${connection.playerId}" }
                        return@with
                    }

                    for (item in itemsToRecycle) {
                        svc.inventory.updateInventory { items ->
                            items.map { 
                                if (it.id.equals(item.id, ignoreCase = true)) {
                                    if (it.qty > item.qty) {
                                        it.copy(qty = it.qty - item.qty)
                                    } else {
                                        null
                                    }
                                } else {
                                    it
                                }
                            }.filterNotNull()
                        }
                    }

                    svc.compound.updateResource { resources ->
                        resources.copy(cash = currentCash - cost)
                    }

                    if (recycledOutputItems.isNotEmpty()) {
                        svc.inventory.updateInventory { items ->
                            items + recycledOutputItems
                        }
                    }

                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":true,"buy":true}""")))
                    Logger.info(LogConfigSocketToClient) { "ITEM_BATCH_RECYCLE: instant recycle completed for player ${connection.playerId}" }
                } else {
                    val jobId = UUID.new()
                    val startTime = io.ktor.util.date.getTimeMillis()
                    val timer = dev.deadzone.core.model.game.data.TimerData(
                        start = startTime,
                        length = totalTime.toLong(),
                        data = null
                    )

                    for (item in itemsToRecycle) {
                        svc.inventory.updateInventory { items ->
                            items.map { 
                                if (it.id.equals(item.id, ignoreCase = true)) {
                                    if (it.qty > item.qty) {
                                        it.copy(qty = it.qty - item.qty)
                                    } else {
                                        null
                                    }
                                } else {
                                    it
                                }
                            }.filterNotNull()
                        }
                    }

                    val job = core.model.game.data.BatchRecycleJob(
                        id = jobId,
                        items = recycledOutputItems,
                        start = startTime,
                        end = totalTime
                    )
                    svc.batchRecycleJob.addBatchRecycleJob(job)

                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = server.tasks.impl.BatchRecycleCompleteTask(
                            taskInputBlock = {
                                this.jobId = jobId
                                this.duration = totalTime.seconds
                                this.serverContext = serverContext
                            },
                            stopInputBlock = {
                                this.jobId = jobId
                            }
                        )
                    )

                    val itemsJsonArray = recycledOutputItems.joinToString(",") { item ->
                        """{"id":"${item.id}","type":"${item.type}","qty":${item.qty},"new":true}"""
                    }
                    val timerJson = """{"start":${timer.start},"length":${timer.length}}"""
                    send(PIOSerializer.serialize(buildMsg(saveId, """{"success":true,"id":"$jobId","items":[$itemsJsonArray],"timer":$timerJson}""")))

                    Logger.info(LogConfigSocketToClient) { "ITEM_BATCH_RECYCLE: job $jobId created for player ${connection.playerId}" }
                }
            }

            SaveDataMethod.ITEM_BATCH_RECYCLE_SPEED_UP -> {
                val jobId = data["id"] as? String
                val option = data["option"] as? String

                if (jobId == null || option == null) {
                    val response = ItemBatchRecycleSpeedUpResponse(error = "", success = false, cost = 0)
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_BATCH_RECYCLE_SPEED_UP: missing 'id' or 'option' parameter" }
                    return@with
                }

                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val job = svc.batchRecycleJob.getBatchRecycleJob(jobId)

                if (job == null) {
                    val response = ItemBatchRecycleSpeedUpResponse(error = "", success = false, cost = 0)
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_BATCH_RECYCLE_SPEED_UP: job not found with id=$jobId" }
                    return@with
                }

                val timer = dev.deadzone.core.model.game.data.TimerData(
                    start = job.start,
                    length = job.end.toLong(),
                    data = null
                )

                if (timer.hasEnded()) {
                    val response = ItemBatchRecycleSpeedUpResponse(error = "", success = false, cost = 0)
                    val responseJson = JSON.encode(response)
                    send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
                    Logger.warn(LogConfigSocketToClient) { "ITEM_BATCH_RECYCLE_SPEED_UP: job $jobId has already ended" }
                    return@with
                }

                val secondsRemaining = timer.secondsLeftToEnd()
                val cost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                val currentCash = svc.compound.getResources().cash
                val notEnoughCoinsErrorId = "55"

                val response: ItemBatchRecycleSpeedUpResponse
                var resourceResponse: core.model.game.data.GameResources? = null

                if (currentCash < cost) {
                    response = ItemBatchRecycleSpeedUpResponse(error = notEnoughCoinsErrorId, success = false, cost = cost)
                } else {
                    val newTimer = when (option) {
                        "SpeedUpOneHour" -> timer.reduceBy(1.hours)
                        "SpeedUpTwoHour" -> timer.reduceBy(2.hours)
                        "SpeedUpHalf" -> timer.reduceByHalf()
                        "SpeedUpComplete" -> null
                        "SpeedUpFree" -> if (secondsRemaining <= 300) null else timer
                        else -> timer
                    }

                    if (newTimer == null) {
                        svc.inventory.updateInventory { items ->
                            items + job.items
                        }
                        svc.batchRecycleJob.removeBatchRecycleJob(jobId)

                        serverContext.taskDispatcher.stopTaskFor<server.tasks.impl.BatchRecycleCompleteStopParameter>(
                            connection = connection,
                            category = server.tasks.TaskCategory.BatchRecycle.Complete,
                            stopInputBlock = {
                                this.jobId = jobId
                            }
                        )
                    } else {
                        val updatedJob = job.copy(
                            start = newTimer.start,
                            end = newTimer.length.toInt()
                        )
                        svc.batchRecycleJob.updateBatchRecycleJob(jobId) { updatedJob }

                        serverContext.taskDispatcher.stopTaskFor<server.tasks.impl.BatchRecycleCompleteStopParameter>(
                            connection = connection,
                            category = server.tasks.TaskCategory.BatchRecycle.Complete,
                            stopInputBlock = {
                                this.jobId = jobId
                            }
                        )

                        serverContext.taskDispatcher.runTaskFor(
                            connection = connection,
                            taskToRun = server.tasks.impl.BatchRecycleCompleteTask(
                                taskInputBlock = {
                                    this.jobId = jobId
                                    this.duration = newTimer.secondsLeftToEnd().seconds
                                    this.serverContext = serverContext
                                },
                                stopInputBlock = {
                                    this.jobId = jobId
                                }
                            )
                        )
                    }

                    svc.compound.updateResource { resources ->
                        resourceResponse = resources.copy(cash = currentCash - cost)
                        resourceResponse
                    }

                    response = ItemBatchRecycleSpeedUpResponse(error = "", success = true, cost = cost)
                }

                val responseJson = JSON.encode(response)
                val resourceResponseJson = JSON.encode(resourceResponse)
                send(PIOSerializer.serialize(buildMsg(saveId, responseJson, resourceResponseJson)))
                Logger.info(LogConfigSocketToClient) { "ITEM_BATCH_RECYCLE_SPEED_UP: job $jobId sped up with option $option for player ${connection.playerId}" }
            }

            SaveDataMethod.ITEM_BATCH_DISPOSE -> {
                Logger.warn(LogConfigSocketToClient) { "Received 'ITEM_BATCH_DISPOSE' message [not implemented]" }
            }
        }
    }
}
