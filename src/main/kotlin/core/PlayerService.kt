package core

interface PlayerService {
    
    suspend fun init(playerId: String): Result<Unit>

    suspend fun close(playerId: String): Result<Unit>
}
