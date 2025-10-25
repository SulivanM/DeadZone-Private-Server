package server.handler.save.compound.task

import context.requirePlayerContext
import dev.deadzone.socket.handler.save.SaveHandlerContext
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
import utils.Logger
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

class TaskSaveHandler : SaveSubHandler {
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
                Logger.info(LogConfigSocketToClient) { "Task cancelled: taskId=$taskId, type=$taskType" }

                if (taskType == "junk_removal" && taskId != null) {
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
                Logger.info(LogConfigSocketToClient) { "Task speed up: taskId=$taskId" }

                send(PIOSerializer.serialize(buildMsg(saveId, "{}")))
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