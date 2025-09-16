package socket.handler.save.compound.task

import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger
import dev.deadzone.socket.core.Connection
import dev.deadzone.context.ServerContext
import dev.deadzone.socket.messaging.SaveDataMethod
import dev.deadzone.socket.handler.buildMsg
import dev.deadzone.socket.protocol.PIOSerializer
import dev.deadzone.context.GlobalContext
import dev.deadzone.socket.handler.save.SaveSubHandler
import kotlinx.serialization.Serializable

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

    override suspend fun handle(
        connection: Connection,
        type: String,
        saveId: String,
        data: Map<String, Any?>,
        send: suspend (ByteArray) -> Unit,
        serverContext: ServerContext
    ) {
        when (type) {
            SaveDataMethod.TASK_STARTED -> {
                val taskType = data["type"] as? String
                val targetId = data["targetId"] as? String
                val survivors = data["survivors"] as? List<*>

                Logger.info(LogConfigSocketToClient) { "Task started: type=$taskType, targetId=$targetId, survivors=${survivors?.size}" }

                val items = when (taskType) {
                    "junk_removal" -> generateJunkRemovalItems()
                    "scavenging" -> generateScavengingItems()
                    "construction" -> generateConstructionItems()
                    else -> emptyList()
                }

                val responseJson = GlobalContext.json.encodeToString(
                    TaskStartedResponse(items = items)
                )

                send(PIOSerializer.serialize(buildMsg(saveId, responseJson)))
            }

            SaveDataMethod.TASK_CANCELLED -> {
                val taskId = data["taskId"] as? String
                Logger.info(LogConfigSocketToClient) { "Task cancelled: taskId=$taskId" }

                send(PIOSerializer.serialize(buildMsg(saveId, "{}")))
            }

            SaveDataMethod.TASK_SURVIVOR_ASSIGNED -> {
                val taskId = data["taskId"] as? String
                val survivors = data["survivors"] as? List<*>
                Logger.info(LogConfigSocketToClient) { "Survivors assigned to task: taskId=$taskId, survivors=${survivors?.size}" }

                send(PIOSerializer.serialize(buildMsg(saveId, "{}")))
            }

            SaveDataMethod.TASK_SURVIVOR_REMOVED -> {
                val taskId = data["taskId"] as? String
                val survivors = data["survivors"] as? List<*>
                Logger.info(LogConfigSocketToClient) { "Survivors removed from task: taskId=$taskId, survivors=${survivors?.size}" }

                send(PIOSerializer.serialize(buildMsg(saveId, "{}")))
            }

            SaveDataMethod.TASK_SPEED_UP -> {
                val taskId = data["taskId"] as? String
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