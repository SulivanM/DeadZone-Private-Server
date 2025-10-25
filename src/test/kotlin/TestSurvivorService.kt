import core.model.game.data.Survivor
import core.survivor.SurvivorRepository
import core.survivor.SurvivorService
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

class TestSurvivorService {

    @Test
    fun testInitLoadsSurvivors() = runBlocking {
        val mockRepo = MockSurvivorRepository()
        val service = SurvivorService("leader1", mockRepo)

        val result = service.init("player1")

        assertTrue(result.isSuccess)
        assertEquals(2, service.getAllSurvivors().size)
    }

    @Test
    fun testGetSurvivorLeader() = runBlocking {
        val mockRepo = MockSurvivorRepository()
        val service = SurvivorService("leader1", mockRepo)
        service.init("player1")

        val leader = service.getSurvivorLeader()

        assertNotNull(leader)
        assertEquals("leader1", leader.id)
        assertEquals("Leader", leader.firstName)
    }

    @Test
    fun testAddNewSurvivorSuccess() = runBlocking {
        val mockRepo = MockSurvivorRepository()
        val service = SurvivorService("leader1", mockRepo)
        service.init("player1")

        val newSurvivor = Survivor(
            id = "srv3",
            title = "Scout",
            firstName = "John",
            lastName = "Doe",
            gender = "male",
            classId = "scout",
            voice = "male1"
        )

        val result = service.addNewSurvivor(newSurvivor)

        assertTrue(result.isSuccess)
        assertEquals(3, service.getAllSurvivors().size)
    }

    @Test
    fun testAddNewSurvivorFailure() = runBlocking {
        val mockRepo = MockSurvivorRepository(shouldFail = true)
        val service = SurvivorService("leader1", mockRepo)
        service.init("player1")

        val newSurvivor = Survivor(
            id = "srv3",
            title = "Scout",
            firstName = "John",
            lastName = "Doe",
            gender = "male",
            classId = "scout",
            voice = "male1"
        )

        val result = service.addNewSurvivor(newSurvivor)

        assertTrue(result.isFailure)
        assertEquals(2, service.getAllSurvivors().size)
    }

    @Test
    fun testUpdateSurvivorSuccess() = runBlocking {
        val mockRepo = MockSurvivorRepository()
        val service = SurvivorService("leader1", mockRepo)
        service.init("player1")

        val result = service.updateSurvivor("srv2") { survivor ->
            survivor.copy(level = 10, xp = 500)
        }

        assertTrue(result.isSuccess)
        val updated = service.getAllSurvivors().find { it.id == "srv2" }
        assertNotNull(updated)
        assertEquals(10, updated.level)
        assertEquals(500, updated.xp)
    }

    @Test
    fun testUpdateSurvivorNotFound() = runBlocking {
        val mockRepo = MockSurvivorRepository()
        val service = SurvivorService("leader1", mockRepo)
        service.init("player1")

        val result = service.updateSurvivor("nonexistent") { it }

        assertTrue(result.isFailure)
    }

    @Test
    fun testUpdateSurvivorFailure() = runBlocking {
        val mockRepo = MockSurvivorRepository(shouldFail = true)
        val service = SurvivorService("leader1", mockRepo)
        service.init("player1")

        val result = service.updateSurvivor("srv2") { survivor ->
            survivor.copy(level = 10)
        }

        assertTrue(result.isFailure)
    }

    @Test
    fun testUpdateSurvivorsSuccess() = runBlocking {
        val mockRepo = MockSurvivorRepository()
        val service = SurvivorService("leader1", mockRepo)
        service.init("player1")

        val updatedList = listOf(
            Survivor(
                id = "leader1",
                title = "Leader",
                firstName = "Leader",
                lastName = "Updated",
                gender = "male",
                classId = "leader",
                voice = "male1"
            )
        )

        val result = service.updateSurvivors(updatedList)

        assertTrue(result.isSuccess)
        assertEquals(1, service.getAllSurvivors().size)
    }

    @Test
    fun testInitAppliesDefaultLastName() = runBlocking {
        val mockRepo = MockSurvivorRepository(includeEmptyLastName = true)
        val service = SurvivorService("leader1", mockRepo)

        service.init("player1")

        val survivor = service.getAllSurvivors().find { it.id == "srv2" }
        assertNotNull(survivor)
        assertEquals("DZ", survivor.lastName)
    }
}

class MockSurvivorRepository(
    private val shouldFail: Boolean = false,
    private val includeEmptyLastName: Boolean = false
) : SurvivorRepository {
    override suspend fun getSurvivors(playerId: String): Result<List<Survivor>> {
        val survivors = listOf(
            Survivor(
                id = "leader1",
                title = "Leader",
                firstName = "Leader",
                lastName = "Smith",
                gender = "male",
                classId = "leader",
                voice = "male1"
            ),
            Survivor(
                id = "srv2",
                title = "Fighter",
                firstName = "Fighter",
                lastName = if (includeEmptyLastName) "" else "Jones",
                gender = "female",
                classId = "fighter",
                voice = "female1"
            )
        )
        return Result.success(survivors)
    }

    override suspend fun addSurvivor(playerId: String, survivor: Survivor): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Add failed"))
        else Result.success(Unit)
    }

    override suspend fun updateSurvivor(playerId: String, survivorId: String, survivor: Survivor): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Update failed"))
        else Result.success(Unit)
    }

    override suspend fun updateSurvivors(playerId: String, survivors: List<Survivor>): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Update failed"))
        else Result.success(Unit)
    }
}
