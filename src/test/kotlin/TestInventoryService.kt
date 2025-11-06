import core.items.InventoryRepository
import core.items.InventoryService
import core.items.model.Item
import data.collection.Inventory
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class TestInventoryService {

    @Test
    fun testInitLoadsInventory() = runTest {
        val mockRepo = MockInventoryRepository()
        val service = InventoryService(mockRepo)

        val result = service.init("player1")

        assertTrue(result.isSuccess)
        assertEquals(2, service.getInventory().size)
        assertEquals(3, service.getSchematics().size)
    }

    @Test
    fun testUpdateInventorySuccess() = runTest {
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
    fun testUpdateInventoryFailure() = runTest {
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
    fun testUpdateSchematicsSuccess() = runTest {
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
    fun testUpdateSchematicsFailure() = runTest {
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
    override suspend fun getInventory(playerId: String): Result<Inventory> {
        return Result.success(
            Inventory(
                inventory = listOf(
                    Item(type = "pipe", qty = 5u),
                    Item(type = "metal", qty = 10u)
                ),
                schematics = byteArrayOf(1, 2, 3),
                playerId = playerId
            )
        )
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
