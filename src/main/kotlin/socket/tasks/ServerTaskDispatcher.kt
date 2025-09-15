package dev.deadzone.socket.tasks

import dev.deadzone.socket.core.Connection
import dev.deadzone.utils.LogConfigSocketError
import dev.deadzone.utils.LogSource
import dev.deadzone.utils.Logger
import kotlinx.coroutines.*
import java.util.UUID
import kotlin.collections.component1
import kotlin.coroutines.cancellation.CancellationException
import kotlin.coroutines.coroutineContext

/**
 * Manages and dispatches registered [ServerTask]s for each playerId or connection
 *
 * This is used to register tasks that the server runs independently, usually
 * to push messages to the connected clients (e.g., time update, real-time events).
 *
 * @property registeredTasks keep tracks registered tasks
 * @property defaultConfigs config for each task. The default config can be overridden from [runTask].
 * @property runningInstances list of globally unique running tasks
 */
class ServerTaskDispatcher : TaskScheduler {
    // taskKey -> template
    private val registeredTasks = mutableMapOf<TaskTemplate, ServerTask>()

    // taskKey -> default config
    private val defaultConfigs = mutableMapOf<TaskTemplate, TaskConfig>()

    // unique task id -> task instance
    private val runningInstances = mutableMapOf<UUID, TaskInstance>()

    // completion listener

    fun register(task: ServerTask) {
        registeredTasks[task.key] = task
        defaultConfigs[task.key] = task.config
    }

    /**
     * Run a task for the socket connection, returning the task ID (UUID).
     */
    fun runTask(
        connection: Connection,
        taskTemplateKey: TaskTemplate,
        cfgBuilder: (TaskConfig) -> TaskConfig?,
        onComplete: (() -> Unit)? = null
    ): UUID {
        val task = requireNotNull(registeredTasks[taskTemplateKey]) { "Task not registered: $taskTemplateKey" }
        val defaultCfg = requireNotNull(defaultConfigs[taskTemplateKey]) { "Missing default config for $taskTemplateKey" }
        val cfg = cfgBuilder(defaultCfg) ?: defaultCfg

        val taskId = UUID.randomUUID()

        val job = connection.scope.launch {
            try {
                Logger.debug(LogSource.SOCKET) { "Push task ${task.key} is going to run." }
                val scheduler = task.scheduler ?: this@ServerTaskDispatcher
                scheduler.schedule(task, connection, cfg)
            } catch (_: CancellationException) {
                Logger.debug(LogSource.SOCKET) { "Push task '${task.key}' was cancelled." }
            } catch (e: Exception) {
                Logger.error(LogConfigSocketError) { "Error running push task '${task.key}': $e" }
            } finally {
                Logger.debug(LogSource.SOCKET) { "Push task ${task.key} has finished running." }
                runningInstances.remove(taskId)
                onComplete?.invoke()
            }
        }

        runningInstances[taskId] = TaskInstance(connection.playerId, taskTemplateKey, cfg, job, onComplete)
        return taskId
    }

    fun stopTask(taskId: UUID) {
        runningInstances.remove(taskId)?.job?.cancel()
    }

    fun stopAllTasksForPlayer(playerId: String) {
        runningInstances
            .filterValues { it.playerId == playerId }
            .forEach { (taskId, _) -> stopTask(taskId) }
    }

    override suspend fun schedule(
        task: ServerTask,
        connection: Connection,
        cfg: TaskConfig
    ) {
        delay(cfg.initialRunDelay)

        val shouldRunInfinitely = cfg.repeatDelay != null
        if (shouldRunInfinitely) {
            while (coroutineContext.isActive) {
                delay(cfg.repeatDelay)
                task.run(connection, cfg)
            }
        } else {
            task.run(connection, cfg)
        }
    }

    fun stopAllPushTasks() {
        runningInstances.forEach { (taskId, _) -> stopTask(taskId) }
    }

    fun shutdown() {
        registeredTasks.clear()
        defaultConfigs.clear()
        stopAllPushTasks()
    }
}

/**
 * An instance of task.
 *
 * @property playerId the player the task belongs to.
 * @property taskKey the [ServerTask] identifier.
 * @property config the configuration of the task.
 * @property job coroutine reference for the task.
 * @property onComplete callback after task has finished running.
 */
data class TaskInstance(
    val playerId: String,
    val taskKey: TaskTemplate,
    val config: TaskConfig,
    val job: Job,
    val onComplete: (() -> Unit)?
)
