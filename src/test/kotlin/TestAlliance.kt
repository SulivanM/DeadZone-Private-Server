import core.model.game.data.alliance.AllianceLifetimeStats
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
import kotlin.test.assertNotNull
import kotlin.test.assertNull

/**
 * Test suite for Alliance functionality
 * Tests alliance creation, membership, and stats
 */
class TestAlliance {

    @Test
    fun testCreateAlliance() = runBlocking {
        val mockDb = MockAllianceDB()
        
        val alliance = Alliance(
            allianceId = "alliance-123",
            name = "Test Alliance",
            tag = "TEST",
            createdAt = System.currentTimeMillis(),
            createdBy = "player-123",
            memberCount = 1
        )
        
        mockDb.createAlliance(alliance)
        
        val retrieved = mockDb.getAlliance("alliance-123")
        assertNotNull(retrieved)
        assertEquals("Test Alliance", retrieved.name)
        assertEquals("TEST", retrieved.tag)
    }

    @Test
    fun testAddAllianceMember() = runBlocking {
        val mockDb = MockAllianceDB()
        
        // Create alliance first
        val alliance = Alliance(
            allianceId = "alliance-123",
            name = "Test Alliance",
            tag = "TEST",
            createdAt = System.currentTimeMillis(),
            createdBy = "player-123",
            memberCount = 1
        )
        mockDb.createAlliance(alliance)
        
        // Add member
        val member = AllianceMember(
            allianceId = "alliance-123",
            playerId = "player-123",
            joinedAt = System.currentTimeMillis(),
            rank = 0,
            lifetimeStats = AllianceLifetimeStats()
        )
        mockDb.addAllianceMember(member)
        
        val retrieved = mockDb.getPlayerAllianceMembership("player-123")
        assertNotNull(retrieved)
        assertEquals("alliance-123", retrieved.allianceId)
        assertEquals(0, retrieved.rank)
    }

    @Test
    fun testUpdateAllianceMemberStats() = runBlocking {
        val mockDb = MockAllianceDB()
        
        // Create alliance and member
        val alliance = Alliance(
            allianceId = "alliance-123",
            name = "Test Alliance",
            tag = "TEST",
            createdAt = System.currentTimeMillis(),
            createdBy = "player-123",
            memberCount = 1
        )
        mockDb.createAlliance(alliance)
        
        val member = AllianceMember(
            allianceId = "alliance-123",
            playerId = "player-123",
            joinedAt = System.currentTimeMillis(),
            rank = 0,
            lifetimeStats = AllianceLifetimeStats(points = 100, kills = 10)
        )
        mockDb.addAllianceMember(member)
        
        // Update stats
        val updatedMember = member.copy(
            lifetimeStats = AllianceLifetimeStats(points = 200, kills = 20)
        )
        mockDb.updateAllianceMember(updatedMember)
        
        val retrieved = mockDb.getPlayerAllianceMembership("player-123")
        assertNotNull(retrieved)
        assertNotNull(retrieved.lifetimeStats)
        assertEquals(200, retrieved.lifetimeStats?.points)
        assertEquals(20, retrieved.lifetimeStats?.kills)
    }

    @Test
    fun testRemoveAllianceMember() = runBlocking {
        val mockDb = MockAllianceDB()
        
        // Create alliance and member
        val alliance = Alliance(
            allianceId = "alliance-123",
            name = "Test Alliance",
            tag = "TEST",
            createdAt = System.currentTimeMillis(),
            createdBy = "player-123",
            memberCount = 1
        )
        mockDb.createAlliance(alliance)
        
        val member = AllianceMember(
            allianceId = "alliance-123",
            playerId = "player-123",
            joinedAt = System.currentTimeMillis(),
            rank = 0
        )
        mockDb.addAllianceMember(member)
        
        // Remove member
        mockDb.removeAllianceMember("player-123")
        
        val retrieved = mockDb.getPlayerAllianceMembership("player-123")
        assertNull(retrieved)
    }

    @Test
    fun testGetAllianceMembers() = runBlocking {
        val mockDb = MockAllianceDB()
        
        // Create alliance
        val alliance = Alliance(
            allianceId = "alliance-123",
            name = "Test Alliance",
            tag = "TEST",
            createdAt = System.currentTimeMillis(),
            createdBy = "player-123",
            memberCount = 3
        )
        mockDb.createAlliance(alliance)
        
        // Add members
        mockDb.addAllianceMember(AllianceMember(
            allianceId = "alliance-123",
            playerId = "player-1",
            joinedAt = System.currentTimeMillis(),
            rank = 0
        ))
        mockDb.addAllianceMember(AllianceMember(
            allianceId = "alliance-123",
            playerId = "player-2",
            joinedAt = System.currentTimeMillis(),
            rank = 1
        ))
        mockDb.addAllianceMember(AllianceMember(
            allianceId = "alliance-123",
            playerId = "player-3",
            joinedAt = System.currentTimeMillis(),
            rank = 2
        ))
        
        val members = mockDb.getAllianceMembers("alliance-123")
        assertEquals(3, members.size)
    }
}

class MockAllianceDB : BigDB {
    private val alliances = mutableMapOf<String, Alliance>()
    private val members = mutableMapOf<String, AllianceMember>()
    
    override suspend fun loadPlayerAccount(playerId: String): PlayerAccount? = null
    override suspend fun loadPlayerObjects(playerId: String): PlayerObjects? = null
    override suspend fun loadNeighborHistory(playerId: String): NeighborHistory? = null
    override suspend fun loadInventory(playerId: String): Inventory? = null
    override suspend fun updatePlayerObjectsJson(playerId: String, updatedPlayerObjects: PlayerObjects) {}
    override fun <T> getCollection(name: CollectionName): T = throw NotImplementedError()
    override suspend fun createUser(username: String, password: String): String = "new-user-id"
    override suspend fun saveArenaLeaderboardEntry(entry: ArenaLeaderboardEntry) {}
    override suspend fun getArenaLeaderboard(arenaName: String, limit: Int): List<ArenaLeaderboardEntry> = emptyList()
    override suspend fun saveActiveArenaSession(session: core.model.game.data.arena.ActiveArenaSession) {}
    override suspend fun getActiveArenaSession(sessionId: String): core.model.game.data.arena.ActiveArenaSession? = null
    override suspend fun getActiveArenaSessionsForPlayer(playerId: String): List<core.model.game.data.arena.ActiveArenaSession> = emptyList()
    override suspend fun deleteActiveArenaSession(sessionId: String) {}
    
    override suspend fun createAlliance(alliance: Alliance) {
        alliances[alliance.allianceId] = alliance
    }
    
    override suspend fun getAlliance(allianceId: String): Alliance? {
        return alliances[allianceId]
    }
    
    override suspend fun updateAlliance(alliance: Alliance) {
        alliances[alliance.allianceId] = alliance
    }
    
    override suspend fun addAllianceMember(member: AllianceMember) {
        members[member.playerId] = member
    }
    
    override suspend fun getAllianceMembers(allianceId: String): List<AllianceMember> {
        return members.values.filter { it.allianceId == allianceId }
    }
    
    override suspend fun getPlayerAllianceMembership(playerId: String): AllianceMember? {
        return members[playerId]
    }
    
    override suspend fun updateAllianceMember(member: AllianceMember) {
        members[member.playerId] = member
    }
    
    override suspend fun removeAllianceMember(playerId: String) {
        members.remove(playerId)
    }
    
    override suspend fun shutdown() {}
}
