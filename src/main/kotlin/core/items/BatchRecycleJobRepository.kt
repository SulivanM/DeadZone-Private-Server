package core.items

import core.model.game.data.BatchRecycleJob

interface BatchRecycleJobRepository {
    suspend fun getBatchRecycleJobs(playerId: String): Result<List<BatchRecycleJob>>
    suspend fun addBatchRecycleJob(playerId: String, job: BatchRecycleJob): Result<Unit>
    suspend fun updateBatchRecycleJob(playerId: String, jobId: String, job: BatchRecycleJob): Result<Unit>
    suspend fun removeBatchRecycleJob(playerId: String, jobId: String): Result<Unit>
}
