package server.tasks.impl

import context.ServerContext
import context.requirePlayerContext
import core.model.game.data.copy
import core.model.game.data.level
import core.model.game.data.upgrade
import core.model.game.data.repair
import server.core.Connection
import server.messaging.NetworkMessage
import server.tasks.*
import utils.LogConfigSocketError
import utils.Logger
import kotlin.time.Duration

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

    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        val serverContext = taskInput.serverContext
        if (serverContext != null) {
            val compoundService = serverContext.requirePlayerContext(connection.playerId).services.compound
            val building = compoundService.getBuilding(taskInput.buildingId)
            if (building != null) {
                val upgradeData = building.upgrade?.data
                val newLevel = (upgradeData?.get("level") as? Int) ?: (building.level + 1)
                val updateResult = compoundService.updateBuilding(taskInput.buildingId) { bld ->
                    bld.copy(level = newLevel, upgrade = null)
                }
                if (updateResult.isFailure) {
                    Logger.error(LogConfigSocketError) {
                        "Failed to finalize building upgrade for bldId=${taskInput.buildingId}, playerId=${connection.playerId}: ${updateResult.exceptionOrNull()?.message}"
                    }
                }
            }
        }
        connection.sendMessage(NetworkMessage.BUILDING_COMPLETE, taskInput.buildingId)
    }
}

data class BuildingCreateParameter(
    var buildingId: String = "",
    var buildDuration: Duration = Duration.ZERO,
    var serverContext: ServerContext? = null
)

data class BuildingCreateStopParameter(
    var buildingId: String = "",
)

class BuildingRepairTask(
    override val taskInputBlock: BuildingRepairParameter.() -> Unit,
    override val stopInputBlock: BuildingRepairStopParameter.() -> Unit
) : ServerTask<BuildingRepairParameter, BuildingRepairStopParameter>() {
    private val taskInput: BuildingRepairParameter by lazy {
        createTaskInput().apply(taskInputBlock)
    }

    override val category = TaskCategory.Building.Repair
    override val config = TaskConfig(
        startDelay = taskInput.repairDuration
    )
    override val scheduler: TaskScheduler? = null

    override fun createTaskInput(): BuildingRepairParameter = BuildingRepairParameter()
    override fun createStopInput(): BuildingRepairStopParameter = BuildingRepairStopParameter()

    @InternalTaskAPI
    override suspend fun execute(connection: Connection) {
        val serverContext = taskInput.serverContext
        if (serverContext != null) {
            val compoundService = serverContext.requirePlayerContext(connection.playerId).services.compound
            val building = compoundService.getBuilding(taskInput.buildingId)
            if (building != null) {
                val updateResult = compoundService.updateBuilding(taskInput.buildingId) { bld ->
                    bld.copy(repair = null, destroyed = false)
                }
                if (updateResult.isFailure) {
                    Logger.error(LogConfigSocketError) {
                        "Failed to finalize building repair for bldId=${taskInput.buildingId}, playerId=${connection.playerId}: ${updateResult.exceptionOrNull()?.message}"
                    }
                }
            }
        }
        connection.sendMessage(NetworkMessage.BUILDING_COMPLETE, taskInput.buildingId)
    }
}

data class BuildingRepairParameter(
    var buildingId: String = "",
    var repairDuration: Duration = Duration.ZERO,
    var serverContext: ServerContext? = null
)

data class BuildingRepairStopParameter(
    var buildingId: String = "",
)
