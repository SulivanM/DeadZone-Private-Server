package server.handler.save.compound.task

import context.requirePlayerContext
import dev.deadzone.core.model.game.data.secondsLeftToEnd
import dev.deadzone.socket.handler.save.SaveHandlerContext
import io.ktor.util.date.*
import kotlinx.serialization.Serializable
import server.handler.buildMsg
import server.handler.save.SaveSubHandler
import server.messaging.SaveDataMethod
import server.protocol.PIOSerializer
import server.tasks.TaskCategory
import server.tasks.impl.JunkRemovalStopParameter
import server.tasks.impl.JunkRemovalTask
import utils.JSON
import utils.LogConfigSocketToClient
import utils.LogLevel
import utils.Logger
import utils.DataLogger
import utils.SpeedUpCostCalculator
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
    val durationSeconds: Int
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

                DataLogger.event("TaskStarted")
                    .prefixText("Task started")
                    .playerId(connection.playerId)
                    .data("taskType", taskType ?: "unknown")
                    .data("buildingId", buildingId ?: "unknown")
                    .data("taskId", taskId ?: "unknown")
                    .data("length", length)
                    .data("survivorCount", survivors?.size ?: 0)
                    .record()
                    .log(LogLevel.INFO)

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

                    DataLogger.event("JunkRemovalTaskConfig")
                        .playerId(connection.playerId)
                        .data("taskId", taskId)
                        .data("buildingId", buildingId)
                        .data("baseDurationSec", length)
                        .data("survivorCount", numSurvivors)
                        .data("actualDurationSec", actualDuration.inWholeSeconds)
                        .record()
                        .log(LogLevel.INFO)

                    val playerContext = serverContext.requirePlayerContext(connection.playerId)
                    val compoundService = playerContext.services.compound

                    junkRemovalTasks[taskId] = JunkRemovalTaskInfo(
                        taskId = taskId,
                        playerId = connection.playerId,
                        startTime = getTimeMillis(),
                        durationSeconds = actualDuration.inWholeSeconds.toInt()
                    )

                    serverContext.taskDispatcher.runTaskFor(
                        connection = connection,
                        taskToRun = JunkRemovalTask(
                            compoundService = compoundService,
                            taskInputBlock = {
                                this.taskId = taskId
                                this.buildingId = buildingId
                                this.removalDuration = actualDuration
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
                DataLogger.event("TaskCancelled")
                    .prefixText("Task cancelled")
                    .playerId(connection.playerId)
                    .data("taskId", taskId ?: "unknown")
                    .data("taskType", taskType ?: "unknown")
                    .record()
                    .log(LogLevel.INFO)

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
                DataLogger.event("TaskSurvivorAssigned")
                    .prefixText("Survivors assigned to task")
                    .playerId(connection.playerId)
                    .data("taskId", taskId ?: "unknown")
                    .data("survivorCount", survivors?.size ?: 0)
                    .record()
                    .log(LogLevel.INFO)

                send(PIOSerializer.serialize(buildMsg(saveId, "{}")))
            }

            SaveDataMethod.TASK_SURVIVOR_REMOVED -> {
                val taskId = data["id"] as? String
                val survivors = data["survivors"] as? List<*>
                DataLogger.event("TaskSurvivorRemoved")
                    .prefixText("Survivors removed from task")
                    .playerId(connection.playerId)
                    .data("taskId", taskId ?: "unknown")
                    .data("survivorCount", survivors?.size ?: 0)
                    .record()
                    .log(LogLevel.INFO)

                send(PIOSerializer.serialize(buildMsg(saveId, "{}")))
            }

            SaveDataMethod.TASK_SPEED_UP -> {
                val taskId = data["id"] as? String
                val option = data["option"] as? String
                DataLogger.event("TaskSpeedUpRequest")
                    .prefixText("Task speed up requested")
                    .playerId(connection.playerId)
                    .data("taskId", taskId ?: "unknown")
                    .data("option", option ?: "unknown")
                    .record()
                    .log(LogLevel.INFO)

                if (taskId == null || option == null) {
                    val errorResponse = TaskSpeedUpResponse(error = "Missing taskId or option", success = false)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(errorResponse))))
                    return@with
                }

                val taskInfo = junkRemovalTasks[taskId]
                if (taskInfo == null) {
                    DataLogger.event("TaskSpeedUpError")
                        .prefixText("Task not found")
                        .playerId(connection.playerId)
                        .data("taskId", taskId)
                        .data("errorReason", "task_not_found")
                        .record()
                        .log(LogLevel.WARN)
                    val errorResponse = TaskSpeedUpResponse(error = "Task not found", success = false)
                    send(PIOSerializer.serialize(buildMsg(saveId, JSON.encode(errorResponse))))
                    return@with
                }

                val elapsedTimeMs = getTimeMillis() - taskInfo.startTime
                val elapsedSeconds = (elapsedTimeMs / 1000).toInt()
                val secondsRemaining = maxOf(0, taskInfo.durationSeconds - elapsedSeconds)

                DataLogger.event("TaskSpeedUpCalculation")
                    .playerId(connection.playerId)
                    .data("taskId", taskId)
                    .data("elapsedSec", elapsedSeconds)
                    .data("remainingSec", secondsRemaining)
                    .data("totalDurationSec", taskInfo.durationSeconds)
                    .record()
                    .log(LogLevel.VERBOSE)

                val cost = SpeedUpCostCalculator.calculateCost(option, secondsRemaining)
                val svc = serverContext.requirePlayerContext(connection.playerId).services
                val currentCash = svc.compound.getResources().cash

                if (currentCash < cost) {
                    DataLogger.event("TaskSpeedUpError")
                        .prefixText("Not enough cash")
                        .playerId(connection.playerId)
                        .data("taskId", taskId)
                        .data("cost", cost)
                        .data("currentCash", currentCash)
                        .data("errorReason", "insufficient_cash")
                        .record()
                        .log(LogLevel.WARN)
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