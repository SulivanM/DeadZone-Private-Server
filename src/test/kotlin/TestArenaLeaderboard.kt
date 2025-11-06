import core.model.game.data.arena.ActiveArenaSession
import data.collection.Alliance
import data.collection.AllianceMember
import data.collection.ArenaLeaderboardEntry
import data.collection.Inventory
import data.collection.NeighborHistory
import data.collection.PlayerAccount
import data.collection.PlayerObjects
import data.db.BigDB
import data.db.CollectionName
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Test suite for Arena Leaderboard functionality
 * Tests saving, retrieving, and sorting leaderboard entries
 */
class TestArenaLeaderboard {

    @Test
    fun testSaveArenaLeaderboardEntry() = runBlocking {
        val mockDb = MockBigDB()
        
        val entry = ArenaLeaderboardEntry(
            playerId = "player-123",
            playerName = "TestPlayer",
            arenaName = "stadium",
            level = 99,
            points = 1000,
            timestamp = System.currentTimeMillis()
        )
        
        mockDb.saveArenaLeaderboardEntry(entry)
        
        assertEquals(1, mockDb.savedEntries.size)
        assertEquals(entry, mockDb.savedEntries[0])
    }

    @Test
    fun testGetArenaLeaderboard() = runBlocking {
        val mockDb = MockBigDB()
        
        // Add test entries
        val entry1 = ArenaLeaderboardEntry(
            playerId = "player-1",
            playerName = "Player1",
            arenaName = "stadium",
            level = 99,
            points = 1000,
            timestamp = System.currentTimeMillis()
        )
        val entry2 = ArenaLeaderboardEntry(
            playerId = "player-2",
            playerName = "Player2",
            arenaName = "stadium",
            level = 50,
            points = 500,
            timestamp = System.currentTimeMillis()
        )
        val entry3 = ArenaLeaderboardEntry(
            playerId = "player-3",
            playerName = "Player3",
            arenaName = "arena2",
            level = 75,
            points = 750,
            timestamp = System.currentTimeMillis()
        )
        
        mockDb.saveArenaLeaderboardEntry(entry1)
        mockDb.saveArenaLeaderboardEntry(entry2)
        mockDb.saveArenaLeaderboardEntry(entry3)
        
        val leaderboard = mockDb.getArenaLeaderboard("stadium")
        
        assertEquals(2, leaderboard.size)
        assertEquals("Player1", leaderboard[0].playerName)
        assertEquals("Player2", leaderboard[1].playerName)
    }

    @Test
    fun testLeaderboardSorting() = runBlocking {
        val mockDb = MockBigDB()
        
        // Add entries with different levels and points
        val entry1 = ArenaLeaderboardEntry(
            playerId = "player-1",
            playerName = "Player1",
            arenaName = "stadium",
            level = 50,
            points = 1000,
            timestamp = System.currentTimeMillis()
        )
        val entry2 = ArenaLeaderboardEntry(
            playerId = "player-2",
            playerName = "Player2",
            arenaName = "stadium",
            level = 99,
            points = 500,
            timestamp = System.currentTimeMillis()
        )
        val entry3 = ArenaLeaderboardEntry(
            playerId = "player-3",
            playerName = "Player3",
            arenaName = "stadium",
            level = 99,
            points = 1000,
            timestamp = System.currentTimeMillis()
        )
        
        mockDb.saveArenaLeaderboardEntry(entry1)
        mockDb.saveArenaLeaderboardEntry(entry2)
        mockDb.saveArenaLeaderboardEntry(entry3)
        
        val leaderboard = mockDb.getArenaLeaderboard("stadium")
        
        // Should be sorted by level (desc) then points (desc)
        assertEquals(3, leaderboard.size)
        assertEquals("Player3", leaderboard[0].playerName) // level 99, points 1000
        assertEquals("Player2", leaderboard[1].playerName) // level 99, points 500
        assertEquals("Player1", leaderboard[2].playerName) // level 50, points 1000
    }

    @Test
    fun testLeaderboardLimit() = runBlocking {
        val mockDb = MockBigDB()
        
        // Add more than the limit
        for (i in 1..150) {
            mockDb.saveArenaLeaderboardEntry(
                ArenaLeaderboardEntry(
                    playerId = "player-$i",
                    playerName = "Player$i",
                    arenaName = "stadium",
                    level = i,
                    points = i * 10,
                    timestamp = System.currentTimeMillis()
                )
            )
        }
        
        val leaderboard = mockDb.getArenaLeaderboard("stadium", limit = 50)
        
        assertEquals(50, leaderboard.size)
    }
}

class MockBigDB : BigDB {
    val savedEntries = mutableListOf<ArenaLeaderboardEntry>()
    
    override suspend fun loadPlayerAccount(playerId: String): PlayerAccount? = null
    override suspend fun loadPlayerObjects(playerId: String): PlayerObjects? = null
    override suspend fun loadNeighborHistory(playerId: String): NeighborHistory? = null
    override suspend fun loadInventory(playerId: String): Inventory? = null
    override suspend fun updatePlayerObjectsJson(playerId: String, updatedPlayerObjects: PlayerObjects) {}
    override fun <T> getCollection(name: CollectionName): T = throw NotImplementedError()
    override suspend fun createUser(username: String, password: String): String = "new-user-id"
    
    override suspend fun saveArenaLeaderboardEntry(entry: ArenaLeaderboardEntry) {
        // Remove existing entry for same player/arena if it exists
        savedEntries.removeIf { it.playerId == entry.playerId && it.arenaName == entry.arenaName }
        savedEntries.add(entry)
    }
    
    override suspend fun getArenaLeaderboard(arenaName: String, limit: Int): List<ArenaLeaderboardEntry> {
        return savedEntries
            .filter { it.arenaName == arenaName }
            .sortedWith(compareByDescending<ArenaLeaderboardEntry> { it.level }.thenByDescending { it.points })
            .take(limit)
    }

    override suspend fun saveActiveArenaSession(session: ActiveArenaSession) {
        TODO("Not yet implemented")
    }

    override suspend fun getActiveArenaSession(sessionId: String): ActiveArenaSession? {
        TODO("Not yet implemented")
    }

    override suspend fun getActiveArenaSessionsForPlayer(playerId: String): List<ActiveArenaSession> {
        TODO("Not yet implemented")
    }

    override suspend fun deleteActiveArenaSession(sessionId: String) {
        TODO("Not yet implemented")
    }

    override suspend fun createAlliance(alliance: Alliance) {
        TODO("Not yet implemented")
    }

    override suspend fun getAlliance(allianceId: String): Alliance? {
        TODO("Not yet implemented")
    }

    override suspend fun updateAlliance(alliance: Alliance) {
        TODO("Not yet implemented")
    }

    override suspend fun addAllianceMember(member: AllianceMember) {
        TODO("Not yet implemented")
    }

    override suspend fun getAllianceMembers(allianceId: String): List<AllianceMember> {
        TODO("Not yet implemented")
    }

    override suspend fun getPlayerAllianceMembership(playerId: String): AllianceMember? {
        TODO("Not yet implemented")
    }

    override suspend fun updateAllianceMember(member: AllianceMember) {
        TODO("Not yet implemented")
    }

    override suspend fun removeAllianceMember(playerId: String) {
        TODO("Not yet implemented")
    }

    override suspend fun shutdown() {}
}
