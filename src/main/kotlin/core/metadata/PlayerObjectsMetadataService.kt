package core.metadata

import core.PlayerService
import core.metadata.model.PlayerFlags
import common.LogConfigSocketToClient
import common.Logger

class PlayerObjectsMetadataService(
    private val playerObjectsMetadataRepository: PlayerObjectsMetadataRepository
) : PlayerService {
    private var flags: ByteArray = PlayerFlags.newgame() // use newgame flags to avoid null
    private var nickname: String? = null // nickname null will prompt leader creation
    private lateinit var playerId: String

    val repository: PlayerObjectsMetadataRepository
        get() = playerObjectsMetadataRepository

    suspend fun updatePlayerFlags(flags: ByteArray): Result<Unit> {
        val result = playerObjectsMetadataRepository.updatePlayerFlags(playerId, flags)
        result.onFailure {
            Logger.error(LogConfigSocketToClient) { "Error updatePlayerFlags: ${it.message}" }
        }
        result.onSuccess {
            this.flags = flags
        }
        return result
    }

    suspend fun updatePlayerNickname(nickname: String): Result<Unit> {
        val result = playerObjectsMetadataRepository.updatePlayerNickname(playerId, nickname)
        result.onFailure {
            Logger.error(LogConfigSocketToClient) { "Error updatePlayerNickname: ${it.message}" }
        }
        result.onSuccess {
            this.nickname = nickname
        }
        return result
    }

    suspend fun clearNotifications(): Result<Unit> {
        val result = playerObjectsMetadataRepository.clearNotifications(playerId)
        result.onFailure {
            Logger.error(LogConfigSocketToClient) { "Error clearNotifications: ${it.message}" }
        }
        return result
    }

    fun getPlayerFlags() = flags

    override suspend fun init(playerId: String): Result<Unit> {
        return runCatching {
            this.playerId = playerId
            val _flags = playerObjectsMetadataRepository.getPlayerFlags(playerId).getOrThrow()
            val _nickname = playerObjectsMetadataRepository.getPlayerNickname(playerId).getOrThrow()

            flags = _flags
            nickname = _nickname

            if (flags.isEmpty()) {
                Logger.warn(LogConfigSocketToClient) { "flags for playerId=$playerId is empty" }
            }
        }
    }

    override suspend fun close(playerId: String): Result<Unit> {
        return Result.success(Unit)
    }
}
