import core.metadata.PlayerObjectsMetadataRepository
import core.metadata.PlayerObjectsMetadataService
import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertContentEquals
import kotlin.test.assertTrue

class TestPlayerObjectsMetadataService {

    @Test
    fun testInitLoadsFlags() = runBlocking {
        val mockRepo = MockPlayerObjectsMetadataRepository()
        val service = PlayerObjectsMetadataService(mockRepo)

        val result = service.init("player1")

        assertTrue(result.isSuccess)
        assertContentEquals(byteArrayOf(1, 2, 3), service.getPlayerFlags())
    }

    @Test
    fun testUpdatePlayerFlagsSuccess() = runBlocking {
        val mockRepo = MockPlayerObjectsMetadataRepository()
        val service = PlayerObjectsMetadataService(mockRepo)
        service.init("player1")

        val newFlags = byteArrayOf(4, 5, 6)
        val result = service.updatePlayerFlags(newFlags)

        assertTrue(result.isSuccess)
        assertContentEquals(newFlags, service.getPlayerFlags())
    }

    @Test
    fun testUpdatePlayerFlagsFailure() = runBlocking {
        val mockRepo = MockPlayerObjectsMetadataRepository(shouldFail = true)
        val service = PlayerObjectsMetadataService(mockRepo)
        service.init("player1")

        val originalFlags = service.getPlayerFlags().copyOf()
        val newFlags = byteArrayOf(4, 5, 6)
        val result = service.updatePlayerFlags(newFlags)

        assertTrue(result.isFailure)
        assertContentEquals(originalFlags, service.getPlayerFlags())
    }

    @Test
    fun testUpdatePlayerNicknameSuccess() = runBlocking {
        val mockRepo = MockPlayerObjectsMetadataRepository()
        val service = PlayerObjectsMetadataService(mockRepo)
        service.init("player1")

        val result = service.updatePlayerNickname("NewNickname")

        assertTrue(result.isSuccess)
    }

    @Test
    fun testUpdatePlayerNicknameFailure() = runBlocking {
        val mockRepo = MockPlayerObjectsMetadataRepository(shouldFail = true)
        val service = PlayerObjectsMetadataService(mockRepo)
        service.init("player1")

        val result = service.updatePlayerNickname("NewNickname")

        assertTrue(result.isFailure)
    }
}

class MockPlayerObjectsMetadataRepository(private val shouldFail: Boolean = false) : PlayerObjectsMetadataRepository {
    override suspend fun getPlayerFlags(playerId: String): Result<ByteArray> {
        return Result.success(byteArrayOf(1, 2, 3))
    }

    override suspend fun getPlayerNickname(playerId: String): Result<String?> {
        return Result.success("TestPlayer")
    }

    override suspend fun updatePlayerFlags(playerId: String, flags: ByteArray): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Update failed"))
        else Result.success(Unit)
    }

    override suspend fun updatePlayerNickname(playerId: String, nickname: String): Result<Unit> {
        return if (shouldFail) Result.failure(Exception("Update failed"))
        else Result.success(Unit)
    }
}
