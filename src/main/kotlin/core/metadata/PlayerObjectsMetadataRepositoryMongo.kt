package dev.deadzone.core.metadata

import com.mongodb.client.model.Filters
import com.mongodb.client.model.Updates
import com.mongodb.kotlin.client.coroutine.MongoCollection
import dev.deadzone.core.data.runMongoCatching
import dev.deadzone.core.data.runMongoCatchingUnit
import dev.deadzone.data.collection.PlayerObjects
import kotlinx.coroutines.flow.firstOrNull

class PlayerObjectsMetadataRepositoryMongo(
    private val objCollection: MongoCollection<PlayerObjects>
) : PlayerObjectsMetadataRepository {

    override suspend fun getPlayerFlags(playerId: String): Result<ByteArray> {
        return runMongoCatching("No player found with id=$playerId") {
            objCollection
                .find(Filters.eq("playerId", playerId))
                .firstOrNull()
                ?.flags
        }
    }

    override suspend fun updatePlayerFlags(playerId: String, flags: ByteArray): Result<Unit> {
        return runMongoCatchingUnit("No player found with id=$playerId") {
            objCollection
                .updateOne(
                    Filters.eq("playerId", playerId),
                    Updates.set("flags", flags)
                )
                .matchedCount > 0
        }
    }

    override suspend fun getPlayerNickname(playerId: String): Result<String?> {
        return runMongoCatching("No player found with id=$playerId") {
            objCollection
                .find(Filters.eq("playerId", playerId))
                .firstOrNull()
                ?.nickname
        }
    }

    override suspend fun updatePlayerNickname(playerId: String, nickname: String): Result<Unit> {
        return runMongoCatchingUnit("No player found with id=$playerId") {
            objCollection
                .updateOne(
                    Filters.eq("playerId", playerId),
                    Updates.set("nickname", nickname)
                )
                .matchedCount > 0
        }
    }
}
