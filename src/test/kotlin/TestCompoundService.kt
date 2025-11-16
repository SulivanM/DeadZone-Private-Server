import core.compound.CompoundRepository
import core.compound.CompoundService
import core.model.game.data.Building
import core.model.game.data.BuildingLike
import core.model.game.data.GameResources
import core.model.game.data.copy
import core.model.game.data.id
import core.model.game.data.level
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import kotlin.time.Duration.Companion.seconds

class TestCompoundService {

    @Test
    fun testInitLoadsResourcesAndBuildings() = runBlocking {
        val mockRepo = MockCompoundRepository()
        val service = CompoundService(mockRepo)

        val result = service.init("player1")

        assertTrue(result.isSuccess)
        assertEquals(100, service.getResources().wood)
        assertEquals(50, service.getResources().metal)
    }

    @Test
    fun testGetBuilding() = runBlocking {
        val mockRepo = MockCompoundRepository()
        val service = CompoundService(mockRepo)
        service.init("player1")

        val building = service.getBuilding("bld1")

        assertNotNull(building)
        assertEquals("bld1", building.id)
    }

    @Test
    fun testUpdateBuildingSuccess() = runBlocking {
        val mockRepo = MockCompoundRepository()
        val service = CompoundService(mockRepo)
        service.init("player1")

        val result = service.updateBuilding("bld1") { building ->
            building.copy(level = 2)
        }

        assertTrue(result.isSuccess)
        val updated = service.getBuilding("bld1")
        assertNotNull(updated)
        assertEquals(2, updated.level)
    }

    @Test
    fun testUpdateBuildingNotFound() = runBlocking {
        val mockRepo = MockCompoundRepository()
        val service = CompoundService(mockRepo)
        service.init("player1")

        val result = service.updateBuilding("nonexistent") { it }

        assertTrue(result.isFailure)
    }

    @Test
    fun testUpdateBuildingFailure() = runBlocking {
        val mockRepo = MockCompoundRepository(shouldFail = true)
        val service = CompoundService(mockRepo)
        service.init("player1")

        val result = service.updateBuilding("bld1") { building ->
            building.copy(level = 2)
        }

        assertTrue(result.isFailure)
    }

    @Test
    fun testCreateBuildingSuccess() = runBlocking {
        val mockRepo = MockCompoundRepository()
        val service = CompoundService(mockRepo)
        service.init("player1")

        val result = service.createBuilding {
            Building(
                id = "bld3",
                type = "house",
                level = 1
            )
        }

        assertTrue(result.isSuccess)
        val created = service.getBuilding("bld3")
        assertNotNull(created)
    }

    @Test
    fun testCreateBuildingFailure() = runBlocking {
        val mockRepo = MockCompoundRepository(shouldFail = true)
        val service = CompoundService(mockRepo)
        service.init("player1")

        val result = service.createBuilding {
            Building(
                id = "bld3",
                type = "house",
                level = 1
            )
        }

        assertTrue(result.isFailure)
    }

    @Test
    fun testDeleteBuildingSuccess() = runBlocking {
        val mockRepo = MockCompoundRepository()
        val service = CompoundService(mockRepo)
        service.init("player1")

        val result = service.deleteBuilding("bld1")

        assertTrue(result.isSuccess)
        assertEquals(null, service.getBuilding("bld1"))
    }

    @Test
    fun testDeleteBuildingFailure() = runBlocking {
        val mockRepo = MockCompoundRepository(shouldFail = true)
        val service = CompoundService(mockRepo)
        service.init("player1")

        val result = service.deleteBuilding("bld1")

        assertTrue(result.isFailure)
        assertNotNull(service.getBuilding("bld1"))
    }

    @Test
    fun testUpdateResourceSuccess() = runBlocking {
        val mockRepo = MockCompoundRepository()
        val service = CompoundService(mockRepo)
        service.init("player1")

        val result = service.updateResource { resources ->
            resources.copy(wood = resources.wood + 50)
        }

        assertTrue(result.isSuccess)
        assertEquals(150, service.getResources().wood)
    }

    @Test
    fun testUpdateResourceFailure() = runBlocking {
        val mockRepo = MockCompoundRepository(shouldFail = true)
        val service = CompoundService(mockRepo)
        service.init("player1")

        val result = service.updateResource { resources ->
            resources.copy(wood = resources.wood + 50)
        }

        assertTrue(result.isFailure)
        assertEquals(100, service.getResources().wood)
    }

    @Test
    fun testCalculateResource() = runBlocking {
        val mockRepo = MockCompoundRepository()
        val service = CompoundService(mockRepo)
        service.init("player1")

        val amount = service.calculateResource(120.seconds)

        assertEquals(18.0, amount)
    }

    @Test
    fun testUpdateAllBuildingsSuccess() = runBlocking {
        val mockRepo = MockCompoundRepository()
        val service = CompoundService(mockRepo)
        service.init("player1")

        val updatedBuildings = listOf(
            Building(id = "bld1", type = "storage", level = 5)
        )

        val result = service.updateAllBuildings(updatedBuildings)

        assertTrue(result.isSuccess)
        assertEquals(1, service.getBuilding("bld1")?.let { 1 } ?: 0)
    }
}

class MockCompoundRepository(private val shouldFail: Boolean = false) : CompoundRepository {
    override suspend fun getGameResources(playerId: String): Result<GameResources> {
        return Result.success(GameResources(
            wood = 100,
            metal = 50,
            cloth = 30,
            water = 200,
            food = 150,
            ammunition = 80,
            cash = 1000
        ))
    }

    override suspend fun getBuildings(playerId: String): Result<List<BuildingLike>> {
        return Result.success(listOf(
            Building(
                id = "bld1",
                type = "storage",
                level = 1
            ),
            Building(
                id = "bld2",
                type = "resource_wood",
                level = 1
            )
        ))
    }

    override suspend fun updateBuilding(playerId: String, buildingId: String, building: BuildingLike): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Update failed"))
        else Result.success(Unit)
    }

    override suspend fun updateAllBuildings(playerId: String, buildings: List<BuildingLike>): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Update failed"))
        else Result.success(Unit)
    }

    override suspend fun createBuilding(playerId: String, building: BuildingLike): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Create failed"))
        else Result.success(Unit)
    }

    override suspend fun deleteBuilding(playerId: String, buildingId: String): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Delete failed"))
        else Result.success(Unit)
    }

    override suspend fun updateGameResources(playerId: String, resources: GameResources): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Update failed"))
        else Result.success(Unit)
    }
}
