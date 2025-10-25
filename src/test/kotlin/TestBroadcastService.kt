import dev.deadzone.socket.core.BroadcastServer
import kotlinx.coroutines.runBlocking
import server.broadcast.BroadcastMessage
import server.broadcast.BroadcastService
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class TestBroadcastService {

    @Test
    fun testBroadcastMessage() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        BroadcastService.broadcast(BroadcastMessage.plainText("test"))

        assertEquals(1, mockServer.messageCount)
    }

    @Test
    fun testBroadcastString() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        BroadcastService.broadcast("test message")

        assertEquals(1, mockServer.messageCount)
    }

    @Test
    fun testBroadcastPlainText() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        BroadcastService.broadcastPlainText("plain text")

        assertEquals(1, mockServer.messageCount)
    }

    @Test
    fun testBroadcastAdmin() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        BroadcastService.broadcastAdmin("admin message")

        assertEquals(1, mockServer.messageCount)
    }

    @Test
    fun testBroadcastWarning() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        BroadcastService.broadcastWarning("warning message")

        assertEquals(1, mockServer.messageCount)
    }

    @Test
    fun testBroadcastShutdown() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        BroadcastService.broadcastShutdown("Server maintenance")

        assertEquals(1, mockServer.messageCount)
    }

    @Test
    fun testBroadcastItemFound() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        BroadcastService.broadcastItemFound("Player1", "Sword", "Legendary")

        assertEquals(1, mockServer.messageCount)
    }

    @Test
    fun testBroadcastItemCrafted() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        BroadcastService.broadcastItemCrafted("Player1", "Armor")

        assertEquals(1, mockServer.messageCount)
    }

    @Test
    fun testBroadcastAchievement() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        BroadcastService.broadcastAchievement("Player1", "First Blood")

        assertEquals(1, mockServer.messageCount)
    }

    @Test
    fun testGetClientCount() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        val count = BroadcastService.getClientCount()

        assertEquals(5, count)
    }

    @Test
    fun testIsEnabled() = runBlocking {
        val mockServer = MockBroadcastServer()
        BroadcastService.initialize(mockServer)

        assertTrue(BroadcastService.isEnabled())
    }
}

class MockBroadcastServer : BroadcastServer {
    var messageCount = 0

    override suspend fun broadcast(message: BroadcastMessage) {
        messageCount++
    }

    override suspend fun broadcast(message: String) {
        messageCount++
    }

    override fun getClientCount(): Int = 5
}
