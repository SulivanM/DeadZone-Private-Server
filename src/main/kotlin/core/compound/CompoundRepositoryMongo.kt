package dev.deadzone.core.compound

import com.mongodb.client.model.Filters
import com.mongodb.client.model.FindOneAndDeleteOptions
import com.mongodb.client.model.Updates
import com.mongodb.kotlin.client.coroutine.MongoCollection
import dev.deadzone.core.data.runMongoCatching
import dev.deadzone.core.model.game.data.Building
import dev.deadzone.core.model.game.data.BuildingLike
import dev.deadzone.core.model.game.data.GameResources
import dev.deadzone.core.model.game.data.JunkBuilding
import dev.deadzone.data.collection.PlayerObjects
import kotlinx.coroutines.flow.firstOrNull
import org.bson.Document

class CompoundRepositoryMongo(val objCollection: MongoCollection<PlayerObjects>) : CompoundRepository {
    override suspend fun getGameResources(playerId: String): Result<GameResources> {
        return runMongoCatching("No player found with id=$playerId") {
            val filter = Filters.eq("playerId", playerId)
            objCollection
                .find(filter)
                .firstOrNull()
                ?.resources
        }
    }

    override suspend fun updateGameResources(
        playerId: String, newResources: GameResources
    ): Result<Unit> {
        return runMongoCatching {
            val filter = Filters.eq("playerId", playerId)
            val updateSet = Updates.set("resources", newResources)

            val result = objCollection.updateOne(filter, updateSet)

            if (result.matchedCount != 1L) {
                throw NoSuchElementException("No player found with id=$playerId")
            }

            if (result.modifiedCount != 1L) {
                throw NoSuchElementException("No game resource found for playerId=$playerId")
            }

            Unit
        }
    }

    override suspend fun createBuilding(playerId: String, newBuilding: BuildingLike): Result<Unit> {
        return runMongoCatching {
            val filter = Filters.eq("playerId", playerId)
            val updateAdd = Updates.addToSet("buildings", newBuilding)

            objCollection.updateOne(filter, updateAdd)
            Unit
        }
    }

    override suspend fun getBuildings(playerId: String): Result<List<BuildingLike>> {
        return runMongoCatching("No player found with id=$playerId") {
            val filter = Filters.eq("playerId", playerId)
            objCollection
                .find(filter)
                .firstOrNull()
                ?.buildings
        }
    }

    override suspend fun updateBuilding(
        playerId: String,
        bldId: String,
        updatedBuilding: BuildingLike
    ): Result<Unit> {
        return runMongoCatching {
            val filter = Filters.and(
                Filters.eq("playerId", playerId),
                Filters.eq("buildings.id", bldId)
            )
            val update = Updates.set("buildings.$", updatedBuilding)
            val result = objCollection.updateOne(filter, update)

            if (result.matchedCount != 1L) {
                throw NoSuchElementException("No player found with id=$playerId")
            }

            if (result.modifiedCount != 1L) {
                throw NoSuchElementException("No building found for bldId=$bldId on playerId=$playerId")
            }

            Unit
        }
    }

    override suspend fun deleteBuilding(playerId: String, bldId: String): Result<Unit> {
        return runMongoCatching {
            val filter = Filters.eq("playerId", playerId)
            val updateDelete = Updates.pull("buildings", Document("id", bldId))

            val updateResult = objCollection.updateOne(filter, updateDelete)

            if (updateResult.matchedCount != 1L) {
                throw NoSuchElementException("No player found with id=$playerId")
            }

            if (updateResult.modifiedCount != 1L) {
                throw NoSuchElementException("No building found for bldId=$bldId on playerId=$playerId")
            }

            Unit
        }
    }
}
