import kotlinx.serialization.json.Json
import server.protocol.PIODeserializer
import server.protocol.PIOSerializer
import utils.JSON
import kotlin.test.BeforeTest
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * Test suite for PIOSerializer/PIODeserializer
 * Tests serialization and deserialization of various data types
 */
class TestPIOSerializer {

    @BeforeTest
    fun setup() {
        try {
            JSON.json
        } catch (e: UninitializedPropertyAccessException) {
            JSON.initialize(Json {
                prettyPrint = false
                ignoreUnknownKeys = true
            })
        }
    }

    // ========== Basic Type Tests ==========

    @Test
    fun testSerializePrimitiveTypes() {
        val message = listOf("test", "key1", "value1", "key2", 42, "key3", true)
        val serialized = PIOSerializer.serialize(message)

        assertTrue(serialized.isNotEmpty(), "Serialized data should not be empty")

        val deserialized = PIODeserializer.deserialize(serialized)
        assertEquals(7, deserialized.size, "Should have 7 elements")
    }

    @Test
    fun testSerializeMapAsJson() {
        val testMap = mapOf(
            "name" to "John",
            "age" to 30,
            "active" to true
        )

        val message = listOf("testMessage", "data", testMap)
        val serialized = PIOSerializer.serialize(message)

        assertTrue(serialized.isNotEmpty())

        val deserialized = PIODeserializer.deserialize(serialized)
        assertEquals(3, deserialized.size)
        assertEquals("testMessage", deserialized[0])
        assertEquals("data", deserialized[1])
        assertTrue(deserialized[2] is String, "Map should be serialized as JSON string")
    }

    @Test
    fun testSerializeList() {
        val testList = listOf(1, 2, 3, 4, 5)
        val message = listOf("numbers", "values", testList)
        val serialized = PIOSerializer.serialize(message)

        assertTrue(serialized.isNotEmpty())

        val deserialized = PIODeserializer.deserialize(serialized)
        assertEquals(3, deserialized.size)
        assertTrue(deserialized[2] is String, "List should be serialized as JSON string")
    }

    @Test
    fun testSerializeEmptyMap() {
        val message = listOf("test", "data", emptyMap<String, Any>())
        val serialized = PIOSerializer.serialize(message)

        assertTrue(serialized.isNotEmpty())

        val deserialized = PIODeserializer.deserialize(serialized)
        assertEquals(3, deserialized.size)
    }

    @Test
    fun testSerializeEmptyList() {
        val message = listOf("test", "data", emptyList<Any>())
        val serialized = PIOSerializer.serialize(message)

        assertTrue(serialized.isNotEmpty())

        val deserialized = PIODeserializer.deserialize(serialized)
        assertEquals(3, deserialized.size)
    }

    // ========== Arena Leaderboard Tests ==========

    @Test
    fun testSerializeArenaLeaderboardIndexedFormat() {
        // Test the new indexed format (0, 1, 2...) instead of level-keyed
        val leaderboardData = mapOf(
            "0" to mapOf(
                "playerId" to "player-1",
                "playerName" to "Player1",
                "level" to 99,
                "points" to 1000,
                "timestamp" to 1234567890L
            ),
            "1" to mapOf(
                "playerId" to "player-2",
                "playerName" to "Player2",
                "level" to 99,  // Same level as Player1
                "points" to 500,
                "timestamp" to 1234567891L
            ),
            "2" to mapOf(
                "playerId" to "player-3",
                "playerName" to "Player3",
                "level" to 50,
                "points" to 250,
                "timestamp" to 1234567892L
            )
        )

        val response = mapOf(
            "success" to true,
            "data" to leaderboardData,
            "reset" to 1730678400000L
        )

        val responseJson = JSON.encode(response)
        val currentTime = System.currentTimeMillis()
        val message = listOf("r", "m5", currentTime, responseJson)

        val serialized = PIOSerializer.serialize(message)
        assertTrue(serialized.isNotEmpty())

        val deserialized = PIODeserializer.deserialize(serialized)
        assertEquals(4, deserialized.size)
        assertEquals("r", deserialized[0])
        assertEquals("m5", deserialized[1])
        assertEquals(currentTime, deserialized[2])
        assertTrue(deserialized[3] is String)

        val responseStr = deserialized[3] as String
        assertTrue(responseStr.contains("\"success\":true") || responseStr.contains("\"success\": true"))
        assertTrue(responseStr.contains("\"0\""), "Should contain indexed key '0'")
        assertTrue(responseStr.contains("\"1\""), "Should contain indexed key '1'")
        assertTrue(responseStr.contains("\"2\""), "Should contain indexed key '2'")
        assertTrue(responseStr.contains("Player1"))
        assertTrue(responseStr.contains("Player2"))
    }

    @Test
    fun testSerializeNestedComplexStructures() {
        val complexData = mapOf(
            "players" to listOf(
                mapOf("id" to 1, "name" to "Player1", "stats" to mapOf("hp" to 100, "mp" to 50)),
                mapOf("id" to 2, "name" to "Player2", "stats" to mapOf("hp" to 80, "mp" to 70))
            ),
            "metadata" to mapOf(
                "timestamp" to System.currentTimeMillis(),
                "version" to "1.0.0"
            )
        )

        val message = listOf("complex", "data", complexData)
        val serialized = PIOSerializer.serialize(message)

        assertTrue(serialized.isNotEmpty())

        val deserialized = PIODeserializer.deserialize(serialized)
        assertEquals(3, deserialized.size)
        assertTrue(deserialized[2] is String)
    }

    // ========== Edge Case Tests ==========

    @Test
    fun testSerializeNullHandling() {
        val mapWithNull = mapOf(
            "key1" to "value1",
            "key2" to null,
            "key3" to 123
        )

        val message = listOf("test", "data", mapWithNull)
        val serialized = PIOSerializer.serialize(message)

        assertTrue(serialized.isNotEmpty())
    }

    @Test
    fun testSerializeLargeNumbers() {
        val data = mapOf(
            "timestamp" to 1730678400000L,
            "bigInt" to Long.MAX_VALUE,
            "regularInt" to 42
        )

        val message = listOf("test", "numbers", data)
        val serialized = PIOSerializer.serialize(message)

        assertTrue(serialized.isNotEmpty())

        val deserialized = PIODeserializer.deserialize(serialized)
        assertEquals(3, deserialized.size)
    }

    @Test
    fun testSerializeSpecialCharacters() {
        val data = mapOf(
            "name" to "Test \"quoted\" name",
            "description" to "Line 1\nLine 2\tTabbed",
            "unicode" to "Hello 世界 🌍"
        )

        val message = listOf("test", "special", data)
        val serialized = PIOSerializer.serialize(message)

        assertTrue(serialized.isNotEmpty())
    }
}
