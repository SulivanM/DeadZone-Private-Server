package dev.deadzone.core.survivor

import dev.deadzone.core.PlayerService
import dev.deadzone.core.model.game.data.HumanAppearance
import dev.deadzone.core.model.game.data.Survivor
import dev.deadzone.utils.LogConfigSocketError
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

/**
 * Manages survivors.
 */
class SurvivorService(
    val survivorLeaderId: String,
    private val survivorRepository: SurvivorRepository
) : PlayerService {
    private val survivors = mutableListOf<Survivor>()
    private lateinit var playerId: String // for simple debug

    fun getSurvivorLeader(): Survivor {
        return survivors.find { it.id == survivorLeaderId }
            ?: throw NoSuchElementException("Survivor leader is missing for playerId=$playerId")
    }

    fun getAllSurvivors(): List<Survivor> {
        return survivors
    }

    fun getIndexOfSurvivor(srvId: String?): Int {
        val idx = survivors.indexOfFirst { it.id == srvId }
        if (idx == -1) throw NoSuchElementException("Couldn't find survivor of id=$srvId for player=$playerId")
        return idx
    }

    suspend fun updateSurvivor(
        srvId: String, updateAction: suspend (Survivor) -> Survivor
    ) {
        val idx = getIndexOfSurvivor(srvId)!!
        val update = updateAction(survivors[idx])
        val result = survivorRepository.updateSurvivor(playerId, srvId, update)
        result.onFailure {
            Logger.error(LogConfigSocketToClient) { "Error on updateSurvivor: ${it.message}" }
        }
        result.onSuccess {
            survivors[idx] = update
        }
    }

    override suspend fun init(playerId: String): Result<Unit> {
        return runCatching {
            this.playerId = playerId
            val _survivors = survivorRepository.getSurvivors(playerId).getOrThrow()

            if (_survivors.isEmpty()) {
                Logger.warn(LogConfigSocketToClient) { "Survivor for playerId=$playerId is empty" }
            }
            survivors.addAll(_survivors)
        }
    }

    override suspend fun close(playerId: String): Result<Unit> {
        return Result.success(Unit)
    }
}
