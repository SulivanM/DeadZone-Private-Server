package data.db

import data.collection.Alliance
import data.collection.AllianceMember
import data.collection.ArenaLeaderboardEntry
import data.collection.Inventory
import data.collection.NeighborHistory
import data.collection.PlayerAccount
import data.collection.PlayerObjects

enum class CollectionName {
    PLAYER_ACCOUNT_COLLECTION, PLAYER_OBJECTS_COLLECTION,
    NEIGHBOR_HISTORY_COLLECTION, INVENTORY_COLLECTION,
    ARENA_LEADERBOARD_COLLECTION, ACTIVE_ARENA_SESSIONS_COLLECTION,
    ALLIANCES_COLLECTION, ALLIANCE_MEMBERS_COLLECTION,
}

interface BigDB {
    
    suspend fun loadPlayerAccount(playerId: String): PlayerAccount?
    suspend fun loadPlayerObjects(playerId: String): PlayerObjects?
    suspend fun loadNeighborHistory(playerId: String): NeighborHistory?
    suspend fun loadInventory(playerId: String): Inventory?

    suspend fun updatePlayerObjectsJson(playerId: String, updatedPlayerObjects: PlayerObjects)

    fun <T> getCollection(name: CollectionName): T

    suspend fun createUser(username: String, password: String): String

    suspend fun saveArenaLeaderboardEntry(entry: ArenaLeaderboardEntry)

    suspend fun getArenaLeaderboard(arenaName: String, limit: Int = 100): List<ArenaLeaderboardEntry>

    suspend fun saveActiveArenaSession(session: core.model.game.data.arena.ActiveArenaSession)

    suspend fun getActiveArenaSession(sessionId: String): core.model.game.data.arena.ActiveArenaSession?

    suspend fun getActiveArenaSessionsForPlayer(playerId: String): List<core.model.game.data.arena.ActiveArenaSession>

    suspend fun deleteActiveArenaSession(sessionId: String)

    suspend fun createAlliance(alliance: Alliance)

    suspend fun getAlliance(allianceId: String): Alliance?

    suspend fun updateAlliance(alliance: Alliance)

    suspend fun addAllianceMember(member: AllianceMember)

    suspend fun getAllianceMembers(allianceId: String): List<AllianceMember>

    suspend fun getPlayerAllianceMembership(playerId: String): AllianceMember?

    suspend fun updateAllianceMember(member: AllianceMember)

    suspend fun removeAllianceMember(playerId: String)

    suspend fun shutdown()
}
