package socket.tasks

import io.ktor.util.date.getTimeMillis
import socket.core.Connection
import utils.LogConfigSocketError
import utils.LogSource
import utils.Logger
import kotlinx.coroutines.*
import kotlin.collections.component1
import kotlin.coroutines.cancellation.CancellationException
import kotlin.time.DurationUnit
import kotlin.time.toDuration

/**
 * Manages and dispatches task instances.
 *
 * This dispatcher is also a task scheduler (i.e., the default implementation of [TaskScheduler]).
 *
 * @property runningInstances Map of task IDs to currently running [TaskInstance]s.
 * @property stopIdRegistry Map of each [TaskCategory] to a function capable of deriving a task ID
 * from a `playerId`, [TaskCategory], and a generic [StopParam] type.
 * Every [ServerTask] implementation **must** call [registerStopId], typically using its own [ServerTask.deriveId],
 * to register how the dispatcher should compute a task ID for that category when stopping tasks.
 */
class ServerTaskDispatcher : TaskScheduler {
    private val runningInstances = mutableMapOf<String, TaskInstance>()
    private val stopIdRegistry = mutableMapOf<TaskCategory, (String, TaskCategory, Any) -> String>()

    /**
     * Registers a function that derives a task ID for a given task category.
     *
     * It always takes a `String` of [Connection.playerId] and a generic [StopParam] type.
     */
    fun <StopParam : Any> registerStopId(category: TaskCategory, deriveId: (String, TaskCategory, StopParam) -> String) {
        @Suppress("UNCHECKED_CAST")
        stopIdRegistry[category] = { playerId, category, stopParam -> deriveId(playerId, category, stopParam as StopParam) }
    }

    /**
     * Computes task ID for a given player and task category with the generic [StopParam] type.
     *
     * @throws IllegalStateException if no ID derivation function has been registered for the category.
     */
    fun <StopParam : Any> deriveTaskId(playerId: String, category: TaskCategory, stopParam: StopParam): String {
        val f = requireNotNull(stopIdRegistry[category]) { "No deriveId function registered for $category" }
        return f(playerId, category, stopParam)
    }

    /**
     * Run the selected [task] for the player's [Connection].
     */
    fun <ExecParam : Any, StopParam : Any> runTask(
        connection: Connection,
        task: ServerTask<ExecParam, StopParam>,
    ) {
        val taskId = task.deriveId()

        val job = connection.scope.launch {
            try {
                Logger.info(LogSource.SOCKET) { "Task ${task.category} is going to run for playerId=${connection.playerId}" }
                val scheduler = task.scheduler ?: this@ServerTaskDispatcher
                scheduler.schedule(connection, task)
            } catch (_: CancellationException) {
                Logger.info(LogSource.SOCKET) { "Task '${task.category}' was cancelled (via CancellationException) for playerId=${connection.playerId}." }
            } catch (e: Exception) {
                Logger.error(LogConfigSocketError) { "Error on task '${task.category}': $e for playerId=${connection.playerId}" }
            } finally {
                Logger.info(LogSource.SOCKET) { "Task ${task.category} has finished running for playerId=${connection.playerId}" }
                runningInstances.remove(taskId)
            }
        }

        runningInstances[taskId] = TaskInstance(
            taskId = taskId,
            category = task.category,
            playerId = connection.playerId,
            config = task.config,
            job = job
        )
    }

    /**
     * Stop the task of [taskId] by cancelling the associated coroutine job.
     */
    fun stopTask(taskId: String) {
        runningInstances.remove(taskId)?.job?.cancel()
    }

    /**
     * Stop all tasks for the [playerId]
     */
    fun stopAllTasksForPlayer(playerId: String) {
        runningInstances
            .filterValues { it.playerId == playerId }
            .forEach { (taskId, _) -> stopTask(taskId) }
    }

    /**
     * Default implementation of [TaskScheduler].
     *
     * The process at how specifically task lifecycle is handled is documented in [ServerTask].
     */
    @OptIn(SchedulerOnly::class)
    override suspend fun <ExecParam : Any, StopParam : Any> schedule(
        connection: Connection,
        task: ServerTask<ExecParam, StopParam>,
    ) {
        val config = task.config
        val shouldRepeat = config.repeatInterval != null
        var iterationDone = 0
        val startTime = getTimeMillis().toDuration(DurationUnit.MILLISECONDS)

        try {
            task.onStart(connection)
            delay(config.startDelay)

            if (shouldRepeat) {
                while (currentCoroutineContext().isActive) {

                    // Check timeout
                    config.timeout?.let { timeout ->
                        val now = getTimeMillis().toDuration(DurationUnit.MILLISECONDS)
                        if (now - startTime >= timeout) {
                            task.onCancelled(connection, CancellationReason.TIMEOUT)
                            break
                        }
                    }

                    task.onIterationStart(connection)
                    task.execute(connection)
                    task.onIterationComplete(connection)

                    iterationDone++
                    // Check max repeat
                    config.maxRepeats?.let { max ->
                        if (iterationDone >= max) {
                            task.onTaskComplete(connection)
                            break
                        }
                    }

                    delay(config.repeatInterval)
                }
            } else {
                task.execute(connection)
                task.onTaskComplete(connection)
            }
        } catch (e: CancellationException) {
            task.onCancelled(connection, CancellationReason.MANUAL)
            throw e
        } catch (e: Exception) {
            task.onCancelled(connection, CancellationReason.ERROR)
            throw e
        }
    }

    /**
     * Stop every running tasks instances in the server.
     */
    fun stopAllPushTasks() {
        runningInstances.forEach { (taskId, _) -> stopTask(taskId) }
    }

    fun shutdown() {
        stopAllPushTasks()
        runningInstances.clear()
        stopIdRegistry.clear()
    }
}

data class TaskInstance(
    val taskId: String,
    val category: TaskCategory,
    val playerId: String,
    val config: TaskConfig,
    val job: Job,
)
