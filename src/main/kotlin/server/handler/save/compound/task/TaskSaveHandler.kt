package server.handler.save.compound.task

import context.requirePlayerContext
import dev.deadzone.core.model.game.data.secondsLeftToEnd
import server.handler.save.SaveHandlerContext
import io.ktor.util.date.*
import kotlinx.serialization.Serializable
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import server.tasks.TaskCategory
import server.tasks.impl.JunkRemovalStopParameter
import server.tasks.impl.JunkRemovalTask
import common.JSON
import common.LogConfigSocketToClient
import common.Logger
import core.game.SpeedUpCostCalculator
import core.model.game.data.type
import core.model.game.data.level
import kotlin.time.Duration.Companion.seconds

@Serializable
data class TaskStartedResponse(
    val items: List<TaskItem>
)

@Serializable
data class TaskItem(
    val id: String,
    val quantity: Int,
    val quality: String? = null
)

data class JunkRemovalTaskInfo(
    val taskId: String,
    val playerId: String,
    val startTime: Long,
    val durationSeconds: Int,
    val xpReward: Int = 0
)

@Serializable
data class TaskSpeedUpResponse(
    val error: String = "",
    val success: Boolean,
    val cost: Int = 0
)

class TaskSaveHandler : SaveSubHandler {
    companion object {
        private val junkRemovalTasks = mutableMapOf<String, JunkRemovalTaskInfo>()
        
        fun cleanupJunkRemovalTask(taskId: String) {
            junkRemovalTasks.remove(taskId)
        }
    }
    override val supportedTypes: Set<String> = setOf(
        SaveDataMethod.TASK_STARTED,
        SaveDataMethod.TASK_CANCELLED,
        SaveDataMethod.TASK_SURVIVOR_ASSIGNED,
        SaveDataMethod.TASK_SURVIVOR_REMOVED,
        SaveDataMethod.TASK_SPEED_UP
    )

    override suspend fun handle(ctx: SaveHandlerContext) = with(ctx) {
        when (type) {
            SaveDataMethod.TASK_STARTED -> {
                val taskType = data["type"] as? String
                val buildingId = data["buildingId"] as? String
                val taskId = data["id"] as? String
                val survivors = data["survivors"] as? List<*>
                val length = (data["length"] as? Number)?.toInt() ?: 0

                Logger.info(LogConfigSocketToClient) { "Task started: type=$taskType, buildingId=$buildingId, taskId=$taskId, length=$length, survivors=${survivors?.size}" }

                val items = when (taskType) {
                    "junk_removal" -> generateJunkRemovalItems()
                    "scavenging" -> generateScavengingItems()
                    "construction" -> generateConstructionItems()
                    else -> emptyList()
                }

                val responseJson = JSON.encode(
                    TaskStartedResponse(items = items)
                )

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))

                if (taskType == "junk_removal" && taskId != null && buildingId != null && length > 0) {
                    val numSurvivors = survivors?.size ?: 1
                    val actualDuration = if (numSurvivors > 0) {
                        (length / numSurvivors).seconds
                    } else {
                        length.seconds
                    }

                    Logger.info(LogConfigSocketToClient) {
                        "Junk removal task: base=$length seconds, survivors=$numSurvivors, actual duration=$actualDuration"
                    }

                    val playerContext = serverContext.requirePlayerContext(connection.playerId)
                    val compoundService = playerContext.services.compound
                    val survivorService = playerContext.services.survivor

                    // Get XP reward from junk building definition
                    val junkBuilding = compoundService.getBuilding(buildingId)
                    val xpReward = if (junkBuilding != null) {
                        val buildingDef = core.data.GameDefinition.findBuilding(junkBuilding.type)
                        val levelDef = buildingDef?.getLevel(junkBuilding.level)
                        levelDef?.xp ?: 10  // Default 10 XP for junk removal
                    } else {
                        10
                    }

                    junkRemovalTasks[taskId] = JunkRemovalTaskInfo(
                        taskId = taskId,
                        playerId = connection.playerId,
                        startTime = getTimeMillis(),
                        durationSeconds = actualDuration.inWholeSeconds.toInt(),
                        xpReward = xpReward
                    )

                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = JunkRemovalTask(
                            compoundService = compoundService,
                            survivorService = survivorService,
                            serverContext = serverContext,
                            taskInputBlock = {
                                this.taskId = taskId
                                this.buildingId = buildingId
                                this.removalDuration = actualDuration
                                this.xpReward = xpReward
                            },
                            stopInputBlock = {
                                this.taskId = taskId
                            }
                        )
                    )
                }
            }

            SaveDataMethod.TASK_CANCELLED -> {
                val taskId = data["id"] as? String
                val taskType = data["type"] as? String
                Logger.info(LogConfigSocketToClient) { "Task cancelled: taskId=$taskId, type=$taskType" }

                if (taskType == "junk_removal" && taskId != null) {
                    junkRemovalTasks.remove(taskId)
                    
                    serverContext.taskDispatcher.stopTaskFor<JunkRemovalStopParameter>(
                        connection = connection,
                        category = TaskCategory.Task.JunkRemoval,
                        stopInputBlock = {
                            this.taskId = taskId
                        }
                    )
                }

                send(PIOSerializer.serialize(buildMsg(saveId, "{}")))
            }

            SaveDataMethod.TASK_SURVIVOR_ASSIGNED -> {
                val taskId = data["id"] as? String
                val survivors = data["survivors"] as? List<*>
                Logger.info(LogConfigSocketToClient) { "Survivors assigned to task: taskId=$taskId, survivors=${survivors?.size}" }

                send(PIOSerializer.serialize(buildMsg(saveId, "{}")))
            }

            SaveDataMethod.TASK_SURVIVOR_REMOVED -> {
                val taskId = data["id"] as? String
                val survivors = data["survivors"] as? List<*>
                Logger.info(LogConfigSocketToClient) { "Survivors removed from task: taskId=$taskId, survivors=${survivors?.size}" }

                send(PIOSerializer.serialize(buildMsg(saveId, "{}")))
            }

            SaveDataMethod.TASK_SPEED_UP -> {
                val taskId = data["id"] as? String
                val option = data["option"] as? String
                Logger.info(LogConfigSocketToClient) { "Task speed up: taskId=$taskId, option=$option" }

                if (taskId == null || option == null) {
                    val errorResponse = TaskSpeedUpResponse(error = "Missing taskId or option", success = false)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(errorResponse))))
                    return@with
                }

                val taskInfo = junkRemovalTasks[taskId]
                if (taskInfo == null) {
                    Logger.warn(LogConfigSocketToClient) { "Task speed up: task not found with taskId=$taskId" }
                    val errorResponse = TaskSpeedUpResponse(error = "Task not found", success = false)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(errorResponse))))
                    return@with
                }

                val elapsedTimeMs = getTimeMillis() - taskInfo.startTime
                val elapsedSeconds = (elapsedTimeMs / 1000).toInt()
                val secondsRemaining = maxOf(0, taskInfo.durationSeconds - elapsedSeconds)

                Logger.info(LogConfigSocketToClient) { 
                    "Task speed up: elapsed=$elapsedSeconds, remaining=$secondsRemaining, total=${taskInfo.durationSeconds}" 
                }

                val cost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val currentCash = svc.compound.getResources().cash

                if (currentCash < cost) {
                    Logger.warn(LogConfigSocketToClient) { "Task speed up: not enough cash for playerId=${connection.playerId}" }
                    val errorResponse = TaskSpeedUpResponse(error = "55", success = false, cost = cost)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(errorResponse))))
                    return@with
                }

                svc.compound.updateResource { resources ->
                    resources.copy(cash = currentCash - cost)
                }

                junkRemovalTasks.remove(taskId)

                serverContext.taskDispatcher.stopTaskFor<JunkRemovalStopParameter>(
                    connection = connection,
                    category = TaskCategory.Task.JunkRemoval,
                    forceComplete = true,
                    stopInputBlock = {
                        this.taskId = taskId
                    }
                )

                val successResponse = TaskSpeedUpResponse(error = "", success = true, cost = cost)
                send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(successResponse))))
            }
        }
    }

    private fun generateJunkRemovalItems(): List<TaskItem> {
        return listOf(
            TaskItem("scrap_metal", kotlin.random.Random.nextInt(5, 15)),
            TaskItem("wood", kotlin.random.Random.nextInt(3, 10)),
            TaskItem("cloth", kotlin.random.Random.nextInt(2, 8))
        )
    }

    private fun generateScavengingItems(): List<TaskItem> {
        return listOf(
            TaskItem("food", kotlin.random.Random.nextInt(2, 6)),
            TaskItem("water", kotlin.random.Random.nextInt(1, 4)),
            TaskItem("medicine", kotlin.random.Random.nextInt(1, 3))
        )
    }

    private fun generateConstructionItems(): List<TaskItem> {
        return listOf(
            TaskItem("building_materials", kotlin.random.Random.nextInt(10, 25)),
            TaskItem("tools", kotlin.random.Random.nextInt(1, 5))
        )
    }
}