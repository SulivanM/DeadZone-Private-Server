package core.items

import core.PlayerService
import core.model.game.data.BatchRecycleJob
import common.LogConfigSocketError
import common.Logger

class BatchRecycleJobService(
    private val batchRecycleJobRepository: BatchRecycleJobRepository
) : PlayerService {
    private val batchRecycleJobs = mutableListOf<BatchRecycleJob>()
    private lateinit var playerId: String

    fun getBatchRecycleJobs(): List<BatchRecycleJob> {
        return batchRecycleJobs.toList()
    }

    fun getBatchRecycleJob(jobId: String): BatchRecycleJob? {
        return batchRecycleJobs.find { it.id.equals(jobId, ignoreCase = true) }
    }

    suspend fun addBatchRecycleJob(job: BatchRecycleJob): Result<Unit> {
        val result = batchRecycleJobRepository.addBatchRecycleJob(playerId, job)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on addBatchRecycleJob: ${it.message}" }
        }
        result.onSuccess {
            batchRecycleJobs.add(job)
        }
        return result
    }

    suspend fun updateBatchRecycleJob(
        jobId: String,
        updateAction: suspend (BatchRecycleJob) -> BatchRecycleJob
    ): Result<Unit> {
        val jobIndex = batchRecycleJobs.indexOfFirst { it.id.equals(jobId, ignoreCase = true) }
        if (jobIndex == -1) {
            return Result.failure(NoSuchElementException("Batch recycle job with id=$jobId not found"))
        }

        val updatedJob = updateAction(batchRecycleJobs[jobIndex])
        val result = batchRecycleJobRepository.updateBatchRecycleJob(playerId, jobId, updatedJob)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on updateBatchRecycleJob: ${it.message}" }
        }
        result.onSuccess {
            batchRecycleJobs[jobIndex] = updatedJob
        }
        return result
    }

    suspend fun removeBatchRecycleJob(jobId: String): Result<Unit> {
        val result = batchRecycleJobRepository.removeBatchRecycleJob(playerId, jobId)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on removeBatchRecycleJob: ${it.message}" }
        }
        result.onSuccess {
            batchRecycleJobs.removeIf { it.id.equals(jobId, ignoreCase = true) }
        }
        return result
    }

    override suspend fun init(playerId: String): Result<Unit> {
        return runCatching {
            this.playerId = playerId
            val jobs = batchRecycleJobRepository.getBatchRecycleJobs(playerId).getOrThrow()
            batchRecycleJobs.clear()
            batchRecycleJobs.addAll(jobs)
        }
    }

    override suspend fun close(playerId: String): Result<Unit> {
        return Result.success(Unit)
    }
}
