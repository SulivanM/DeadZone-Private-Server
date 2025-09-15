package dev.deadzone.user

import com.mongodb.client.model.Filters
import com.mongodb.client.model.Projections
import com.mongodb.client.model.Updates
import com.mongodb.kotlin.client.coroutine.MongoCollection
import com.toxicbakery.bcrypt.Bcrypt
import dev.deadzone.core.auth.model.UserProfile
import dev.deadzone.data.collection.PlayerAccount
import dev.deadzone.context.GlobalContext
import dev.deadzone.core.data.runMongoCatching
import kotlinx.coroutines.flow.firstOrNull
import org.bson.Document
import kotlin.io.encoding.Base64

/**
 * Player account repository, analogous to game service's repo, though don't have service class, but is used anywhere in server.
 */
class PlayerAccountRepositoryMongo(val userCollection: MongoCollection<PlayerAccount>) : PlayerAccountRepository {
    override suspend fun doesUserExist(username: String): Result<Boolean> {
        return runMongoCatching {
            userCollection
                .find(Filters.eq("profile.displayName", username))
                .projection(null)
                .firstOrNull() != null
        }
    }

    override suspend fun getUserDocByUsername(username: String): Result<PlayerAccount?> {
        return runMongoCatching {
            userCollection.find(Filters.eq("profile.displayName", username)).firstOrNull()
        }
    }

    override suspend fun getUserDocByPlayerId(playerId: String): Result<PlayerAccount?> {
        return runMongoCatching {
            userCollection.find(Filters.eq("playerId", playerId)).firstOrNull()
        }
    }

    override suspend fun getPlayerIdOfUsername(username: String): Result<String?> {
        return runMongoCatching {
            userCollection
                .find(Filters.eq("profile.displayName", username))
                .projection(Projections.include("playerId"))
                .firstOrNull()
                ?.playerId
        }
    }

    override suspend fun getProfileOfPlayerId(playerId: String): Result<UserProfile?> {
        val doc = userCollection
            .withDocumentClass<Document>()
            .find(Filters.eq("playerId", playerId))
            .projection(Projections.include("profile"))
            .firstOrNull()

        val profileDoc = doc?.get("profile") as? Document
        return runMongoCatching {
            profileDoc?.let {
                val jsonString = it.toJson()
                GlobalContext.json.decodeFromString<UserProfile>(jsonString)
            }
        }
    }

    override suspend fun updatePlayerAccount(
        playerId: String,
        account: PlayerAccount
    ): Result<Unit> {
        return runMongoCatching {
            val result = userCollection.replaceOne(Filters.eq("playerId", playerId), account)
            if (result.modifiedCount < 1) {
                throw NoSuchElementException("playerId=$playerId not on updatePlayerAccount")
            }
        }
    }

    override suspend fun updateLastLogin(playerId: String, lastLogin: Long): Result<Unit> {
        return runMongoCatching {
            val result = userCollection.updateOne(
                Filters.eq("playerId", playerId),
                Updates.set("profile.lastLogin", lastLogin)
            )
            if (result.modifiedCount < 1) {
                throw NoSuchElementException("playerId=$playerId not on updateLastLogin")
            }
        }
    }

    override suspend fun verifyCredentials(username: String, password: String): Result<String?> {
        return runMongoCatching {
            val doc = userCollection
                .withDocumentClass<Document>()
                .find(Filters.eq("profile.displayName", username))
                .projection(Projections.include("hashedPassword", "playerId"))
                .firstOrNull()

            if (doc == null) return@runMongoCatching null

            val hashed = doc.getString("hashedPassword")
            val playerId = doc.getString("playerId")
            val matches = Bcrypt.verify(password, Base64.decode(hashed))

            if (matches) playerId else null
        }
    }
}
