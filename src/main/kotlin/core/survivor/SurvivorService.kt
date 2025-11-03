package core.survivor

import core.PlayerService
import core.model.game.data.Survivor
import utils.LogConfigSocketError
import utils.LogLevel
import utils.Logger
import utils.DataLogger
import kotlin.Result.Companion.failure

class SurvivorService(
    val survivorLeaderId: String,
    private val survivorRepository: SurvivorRepository
) : PlayerService {
    private val survivors = mutableListOf<Survivor>()
    private lateinit var playerId: String

    fun getSurvivorLeader(): Survivor {
        return survivors.find { it.id == survivorLeaderId }
            ?: throw NoSuchElementException("Survivor leader is missing for playerId=$playerId")
    }

    fun getAllSurvivors(): List<Survivor> {
        return survivors
    }

    suspend fun addNewSurvivor(survivor: Survivor): Result<Unit> {
        val result = survivorRepository.addSurvivor(playerId, survivor)
        result.onFailure {
            DataLogger.event("SurvivorAddError")
                .prefixText("Error adding new survivor")
                .playerId(playerId)
                .data("survivorId", survivor.id)
                .data("operation", "addNewSurvivor")
                .data("error", it.message ?: "unknown")
                .record()
                .log(LogLevel.ERROR)
        }
        result.onSuccess {
            survivors.add(survivor)
            DataLogger.event("SurvivorAdded")
                .prefixText("Survivor added successfully")
                .playerId(playerId)
                .data("survivorId", survivor.id)
                .data("survivorName", "${survivor.firstName} ${survivor.lastName}")
                .record()
                .log(LogLevel.INFO)
        }
        return result
    }

    suspend fun updateSurvivor(
        srvId: String,
        updateAction: suspend (Survivor) -> Survivor
    ): Result<Unit> {
        val idx = survivors.indexOfFirst { it.id == srvId }
        if (idx == -1) {
            DataLogger.event("SurvivorNotFound")
                .prefixText("Survivor not found")
                .playerId(playerId)
                .data("survivorId", srvId)
                .data("operation", "updateSurvivor")
                .record()
                .log(LogLevel.ERROR)
            return failure(NoSuchElementException("Survivor with id $srvId not found"))
        }
        val currentSurvivor = survivors[idx]
        val updatedSurvivor = updateAction(currentSurvivor)
        val result = survivorRepository.updateSurvivor(playerId, srvId, updatedSurvivor)
        result.onFailure {
            DataLogger.event("SurvivorUpdateError")
                .prefixText("Error updating survivor")
                .playerId(playerId)
                .data("survivorId", srvId)
                .data("operation", "updateSurvivor")
                .data("error", it.message ?: "unknown")
                .record()
                .log(LogLevel.ERROR)
        }
        result.onSuccess {
            survivors[idx] = updatedSurvivor
        }
        return result
    }

    suspend fun updateSurvivors(
        survivors: List<Survivor>
    ): Result<Unit> {
        val result = survivorRepository.updateSurvivors(playerId, survivors)
        result.onFailure {
            DataLogger.event("SurvivorsUpdateError")
                .prefixText("Error updating survivors")
                .playerId(playerId)
                .data("survivorCount", survivors.size)
                .data("operation", "updateSurvivors")
                .data("error", it.message ?: "unknown")
                .record()
                .log(LogLevel.ERROR)
        }
        result.onSuccess {
            this.survivors.clear()
            this.survivors.addAll(survivors)
        }
        return result
    }

    override suspend fun init(playerId: String): Result<Unit> {
        return runCatching {
            this.playerId = playerId
            val loadedSurvivors = survivorRepository.getSurvivors(playerId).getOrThrow()
            if (loadedSurvivors.isEmpty()) {
                DataLogger.event("SurvivorsEmpty")
                    .prefixText("No survivors found for player")
                    .playerId(playerId)
                    .data("operation", "init")
                    .record()
                    .log(LogLevel.WARN)
            }
            survivors.addAll(loadedSurvivors.map { srv ->
                srv.copy(
                    lastName = srv.lastName.takeIf { it.isNotEmpty() } ?: "DZ",
                )
            })
        }
    }

    override suspend fun close(playerId: String): Result<Unit> {
        return Result.success(Unit)
    }
}