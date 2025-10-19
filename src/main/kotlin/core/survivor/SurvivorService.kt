package core.survivor
import core.PlayerService
import core.model.game.data.Survivor
import utils.LogConfigSocketError
import utils.Logger
import kotlin.Result.Companion.failure
import kotlin.math.max

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

    suspend fun addNewSurvivor(survivor: Survivor) {
        val result = survivorRepository.addSurvivor(playerId, survivor)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on addNewSurvivor: ${it.message}" }
        }
        result.onSuccess {
            survivors.add(survivor)
        }
    }

    suspend fun updateSurvivor(
        srvId: String,
        updateAction: suspend (Survivor) -> Survivor
    ) {
        val idx = survivors.indexOfFirst { it.id == srvId }
        if (idx == -1) {
            Logger.error(LogConfigSocketError) { "Survivor with id $srvId not found" }
            return
        }
        val currentSurvivor = survivors[idx]
        val updatedSurvivor = updateAction(currentSurvivor)
        val result = survivorRepository.updateSurvivor(playerId, srvId, updatedSurvivor)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on updateSurvivor: ${it.message}" }
        }
        result.onSuccess {
            survivors[idx] = updatedSurvivor
        }
    }

    suspend fun updateSurvivors(
        survivors: List<Survivor>
    ) {
        val result = survivorRepository.updateSurvivors(playerId, survivors)
        result.onFailure {
            Logger.error(LogConfigSocketError) { "Error on updateSurvivors: ${it.message}" }
        }
        result.onSuccess {
            this.survivors.clear()
            this.survivors.addAll(survivors)
        }
    }

    override suspend fun init(playerId: String): Result<Unit> {
        return runCatching {
            this.playerId = playerId
            val loadedSurvivors = survivorRepository.getSurvivors(playerId).getOrThrow()
            if (loadedSurvivors.isEmpty()) {
                Logger.warn(LogConfigSocketError) { "Survivors for playerId=$playerId is empty" }
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