package dev.deadzone.core.metadata

import dev.deadzone.core.PlayerService
import dev.deadzone.core.model.data.PlayerFlags
import dev.deadzone.utils.LogConfigSocketToClient
import dev.deadzone.utils.Logger

class PlayerObjectsMetadataService(
    private val playerObjectsMetadataRepository: PlayerObjectsMetadataRepository
) : PlayerService {
    private var flags: ByteArray = PlayerFlags.newgame() // use newgame flags to avoid null
    private var nickname: String? = null // nickname null will prompt leader creation
    private lateinit var playerId: String

    suspend fun updatePlayerFlags(flags: ByteArray) {
        val result = playerObjectsMetadataRepository.updatePlayerFlags(playerId, flags)
        result.onFailure {
            Logger.error(LogConfigSocketToClient) { "Error updatePlayerFlags: ${it.message}" }
        }
        result.onSuccess {
            this.flags = flags
        }
    }

    suspend fun updatePlayerNickname(nickname: String) {
        val result = playerObjectsMetadataRepository.updatePlayerNickname(playerId, nickname)
        result.onFailure {
            Logger.error(LogConfigSocketToClient) { "Error updatePlayerNickname: ${it.message}" }
        }
        result.onSuccess {
            this.nickname = nickname
        }
    }

    fun getPlayerFlags() = flags
    fun getPlayerNickname() = nickname

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
