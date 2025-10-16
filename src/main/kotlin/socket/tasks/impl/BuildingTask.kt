package socket.tasks.impl

import socket.core.Connection
import socket.messaging.NetworkMessage
import socket.tasks.*
import kotlin.time.Duration

/**
 * Task for creating and upgrading building with or without cash option.
 *
 * This is used for:
 * - BUILDING_CREATE
 * - BUILDING_CREATE_BUY
 * - BUILDING_UPGRADE
 * - BUILDING_UPGRADE_BUY
 */
class BuildingCreateTask(
    override val taskInputBlock: BuildingCreateParameter.() -> Unit,
    override val stopInputBlock: BuildingCreateStopParameter.() -> Unit
) : ServerTask<BuildingCreateParameter, BuildingCreateStopParameter>() {
    private val taskInput: BuildingCreateParameter by lazy {
        createTaskInput().apply(taskInputBlock)
    }

    override val category = TaskCategory.Building.Create
    override val config = TaskConfig(
        startDelay = taskInput.buildDuration
    )
    override val scheduler: TaskScheduler? = null

    override fun createTaskInput(): BuildingCreateParameter = BuildingCreateParameter()
    override fun createStopInput(): BuildingCreateStopParameter = BuildingCreateStopParameter()

    /**
     * Main execution: waits until `buildDuration` then run `execute()`,
     * which will send BUILDING_COMPLETE message to client.
     */
    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        connection.sendMessage(NetworkMessage.BUILDING_COMPLETE, taskInput.buildingId)
    }

    /**
     * Force complete: typically used when player's speed up the construction.
     * Similarly, send BUILDING_COMPLETE message to client.
     */
    @InternalTaskAPI
    override suspend fun onForceComplete(connection: Connection) {
        connection.sendMessage(NetworkMessage.BUILDING_COMPLETE, taskInput.buildingId)
    }
}

data class BuildingCreateParameter(
    var buildingId: String = "",
    var buildDuration: Duration = Duration.ZERO
)

data class BuildingCreateStopParameter(
    var buildingId: String = "",
)

/**
 * Task for repairing building with or without cash option.
 *
 * This is used for:
 * - BUILDING_REPAIR
 * - BUILDING_REPAIR_BUY
 */
class BuildingRepairTask(
    override val taskInputBlock: BuildingRepairParameter.() -> Unit,
    override val stopInputBlock: BuildingRepairStopParameter.() -> Unit
) : ServerTask<BuildingRepairParameter, BuildingRepairStopParameter>() {
    private val taskInput: BuildingRepairParameter by lazy {
        createTaskInput().apply(taskInputBlock)
    }

    override val category = TaskCategory.Building.Create
    override val config = TaskConfig(
        startDelay = taskInput.repairDuration
    )
    override val scheduler: TaskScheduler? = null

    override fun createTaskInput(): BuildingRepairParameter = BuildingRepairParameter()
    override fun createStopInput(): BuildingRepairStopParameter = BuildingRepairStopParameter()

    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        connection.sendMessage(NetworkMessage.BUILDING_COMPLETE, taskInput.buildingId)
    }
}

data class BuildingRepairParameter(
    var buildingId: String = "",
    var repairDuration: Duration = Duration.ZERO
)

data class BuildingRepairStopParameter(
    var buildingId: String = "",
)
