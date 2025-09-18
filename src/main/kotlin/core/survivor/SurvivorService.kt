package core.survivor
import core.PlayerService
import dev.deadzone.core.model.game.data.Survivor
import dev.deadzone.utils.LogConfigSocketError
import dev.deadzone.utils.Logger
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

    override suspend fun init(playerId: String): Result<Unit> {
        return runCatching {
            this.playerId = playerId
            val loadedSurvivors = survivorRepository.getSurvivors(playerId).getOrThrow()
            if (loadedSurvivors.isEmpty()) {
                Logger.warn(LogConfigSocketError) { "Survivor for playerId=$playerId is empty" }
            }
            survivors.clear()
            survivors.addAll(loadedSurvivors.map { srv ->
                srv.copy(
                    lastName = srv.lastName.takeIf { it.isNotEmpty() } ?: "DZ",
                    level = max(srv.level, 1)
                )
            })
        }
    }

    override suspend fun close(playerId: String): Result<Unit> {
        return runCatching {
            survivorRepository.updateSurvivors(playerId, survivors).getOrThrow()
        }.onFailure {
            Logger.error(LogConfigSocketError) { "Failed to save survivors on close for playerId=$playerId: ${it.message}" }
            failure<Unit>(it) // Spécification explicite du type Unit
        }
    }
}