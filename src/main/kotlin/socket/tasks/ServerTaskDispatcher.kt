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
 * @property stopIdProviders  Map of each [TaskCategory] to a function capable of deriving a task ID
 *                            from a `playerId`, [TaskCategory], and a generic [StopInput] type.
 *                            Every [ServerTask] implementation **must** call [registerStopId] (in Server.kt)
 *                            to register how the dispatcher should compute a task ID for that category when stopping tasks.
 * @property stopInputFactories Map of each [TaskCategory] to a factory function that
 *                              creates a new instance of its corresponding `StopInput` type.
 */
class ServerTaskDispatcher : TaskScheduler {
    private val runningInstances = mutableMapOf<String, TaskInstance>()

    private val stopIdProviders =
        mutableMapOf<TaskCategory, (playerId: String, category: TaskCategory, stopInput: Any) -> String>()

    private val stopInputFactories = mutableMapOf<TaskCategory, () -> Any>()

    /**
     * Registers a function that derives a task ID for a given task category.
     *
     * It always takes a `String` of [Connection.playerId] and a generic [StopInput] type.
     */
    @Suppress("UNCHECKED_CAST")
    fun <StopInput : Any> registerStopId(
        category: TaskCategory,
        stopInputFactory: () -> StopInput,
        deriveId: (playerId: String, category: TaskCategory, stopInput: StopInput) -> String
    ) {
        stopInputFactories[category] = stopInputFactory
        stopIdProviders[category] = { playerId, category, stopInput ->
            deriveId(playerId, category, stopInput as StopInput)
        }
    }

    /**
     * Run the selected [taskToRun] for the player's [Connection].
     */
    fun <TaskInput : Any, StopInput : Any> runTaskFor(
        connection: Connection,
        taskToRun: ServerTask<TaskInput, StopInput>,
    ) {
        val stopInput = taskToRun.createStopInput().apply(taskToRun.stopInputBlock)

        val deriveStopId = stopIdProviders[taskToRun.category]
            ?: error("stopIdProvider not registered for ${taskToRun.category} (register in Server.kt)")
        val taskId = deriveStopId(connection.playerId, taskToRun.category, stopInput)

        val job = connection.scope.launch {
            try {
                Logger.info(LogSource.SOCKET) { "Task ${taskToRun.category} is going to run for playerId=${connection.playerId}" }
                val scheduler = taskToRun.scheduler ?: this@ServerTaskDispatcher
                scheduler.schedule(connection, taskToRun)
            } catch (_: CancellationException) {
                Logger.info(LogSource.SOCKET) { "Task '${taskToRun.category}' was cancelled (via CancellationException) for playerId=${connection.playerId}." }
            } catch (e: Exception) {
                Logger.error(LogConfigSocketError) { "Error on task '${taskToRun.category}': $e for playerId=${connection.playerId}" }
            } finally {
                Logger.info(LogSource.SOCKET) { "Task ${taskToRun.category} has finished running for playerId=${connection.playerId}" }
                runningInstances.remove(taskId)
            }
        }

        runningInstances[taskId] = TaskInstance(
            category = taskToRun.category,
            playerId = connection.playerId,
            config = taskToRun.config,
            job = job
        )
    }

    /**
     * Stop the task of [taskId] by cancelling the associated coroutine job.
     */
    private fun stopTask(taskId: String) {
        runningInstances.remove(taskId)?.job?.cancel()
    }

    /**
     * Stop the task with the given [Connection.playerId], [category], and [StopInput].
     */
    @Suppress("UNCHECKED_CAST")
    fun <StopInput : Any> stopTaskFor(
        connection: Connection,
        category: TaskCategory,
        stopInputBlock: StopInput.() -> Unit = {}
    ) {
        val factory = stopInputFactories[category]
            ?: error("No stopInputFactory registered for $category (register in Server.kt)")
        val stopInput = (factory() as StopInput).apply(stopInputBlock)

        val deriveId = stopIdProviders[category]
            ?: error("No stopIdProvider registered for $category (register in Server.kt)")

        val taskId = deriveId(connection.playerId, category, stopInput)
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
    @OptIn(InternalTaskAPI::class)
    override suspend fun <TaskInput : Any, StopInput : Any> schedule(
        connection: Connection,
        task: ServerTask<TaskInput, StopInput>,
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
        stopIdProviders.clear()
    }
}

data class TaskInstance(
    val category: TaskCategory,
    val playerId: String,
    val config: TaskConfig,
    val job: Job,
)
