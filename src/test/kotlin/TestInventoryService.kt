import core.items.InventoryRepository
import core.items.InventoryService
import core.items.model.InventoryObject
import core.items.model.Item
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class TestInventoryService {

    @Test
    fun testInitLoadsInventory() = runBlocking {
        val mockRepo = MockInventoryRepository()
        val service = InventoryService(mockRepo)

        val result = service.init("player1")

        assertTrue(result.isSuccess)
        assertEquals(2, service.getInventory().size)
        assertEquals(3, service.getSchematics().size)
    }

    @Test
    fun testUpdateInventorySuccess() = runBlocking {
        val mockRepo = MockInventoryRepository()
        val service = InventoryService(mockRepo)
        service.init("player1")

        val result = service.updateInventory { items ->
            items + Item(type = "wood", qty = 10u)
        }

        assertTrue(result.isSuccess)
        assertEquals(3, service.getInventory().size)
    }

    @Test
    fun testUpdateInventoryFailure() = runBlocking {
        val mockRepo = MockInventoryRepository(shouldFail = true)
        val service = InventoryService(mockRepo)
        service.init("player1")

        val result = service.updateInventory { items ->
            items + Item(type = "wood", qty = 10u)
        }

        assertTrue(result.isFailure)
        assertEquals(2, service.getInventory().size)
    }

    @Test
    fun testUpdateSchematicsSuccess() = runBlocking {
        val mockRepo = MockInventoryRepository()
        val service = InventoryService(mockRepo)
        service.init("player1")

        val result = service.updateSchematics { schematics ->
            schematics + byteArrayOf(1, 2, 3)
        }

        assertTrue(result.isSuccess)
        assertEquals(6, service.getSchematics().size)
    }

    @Test
    fun testUpdateSchematicsFailure() = runBlocking {
        val mockRepo = MockInventoryRepository(shouldFail = true)
        val service = InventoryService(mockRepo)
        service.init("player1")

        val result = service.updateSchematics { schematics ->
            schematics + byteArrayOf(1, 2, 3)
        }

        assertTrue(result.isFailure)
        assertEquals(3, service.getSchematics().size)
    }
}

class MockInventoryRepository(private val shouldFail: Boolean = false) : InventoryRepository {
    override suspend fun getInventory(playerId: String): Result<InventoryObject> {
        return Result.success(InventoryObject(
            inventory = listOf(
                Item(type = "pipe", qty = 5u),
                Item(type = "metal", qty = 10u)
            ),
            schematics = byteArrayOf(1, 2, 3)
        ))
    }

    override suspend fun updateInventory(playerId: String, inventory: List<Item>): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Update failed"))
        else Result.success(Unit)
    }

    override suspend fun updateSchematics(playerId: String, schematics: ByteArray): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Update failed"))
        else Result.success(Unit)
    }
}
