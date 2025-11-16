import core.bounty.BountyGenerationService
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue
import kotlin.test.assertFalse

class TestBountyGenerationService {

    @Test
    fun testGenerateInfectedBounty() {
        // Generate a bounty for a test player
        val bounty = BountyGenerationService.generateInfectedBounty("test-player-123")
        
        // Verify bounty has all required fields
        assertNotNull(bounty.id, "Bounty should have an ID")
        assertFalse(bounty.completed, "Bounty should not be completed initially")
        assertFalse(bounty.abandoned, "Bounty should not be abandoned initially")
        assertFalse(bounty.viewed, "Bounty should not be viewed initially")
        assertEquals("", bounty.rewardItemId, "Reward item ID should be empty initially")
        assertTrue(bounty.issueTime > 0, "Bounty should have a valid issue time")
    }
    
    @Test
    fun testBountyHasTasksWithinRange() {
        // Generate a bounty
        val bounty = BountyGenerationService.generateInfectedBounty("test-player-123")
        
        // Verify tasks count is within expected range (1-3)
        assertTrue(bounty.tasks.isNotEmpty(), "Bounty should have at least one task")
        assertTrue(bounty.tasks.size <= 3, "Bounty should have at most 3 tasks")
    }
    
    @Test
    fun testTasksHaveValidSuburbs() {
        // Generate a bounty
        val bounty = BountyGenerationService.generateInfectedBounty("test-player-123")
        
        // Valid suburbs list
        val validSuburbs = listOf(
            "Dartside", "Doddingston", "Greyside_NW", "Greyside_NE", 
            "Greyside_SW", "Greyside_SE", "Nastya's Holdout", "Secronom", "Wasteland"
        )
        
        // Verify each task has a valid suburb
        bounty.tasks.forEach { task ->
            assertTrue(validSuburbs.contains(task.suburb), 
                "Task suburb '${task.suburb}' should be from valid suburbs list")
        }
    }
    
    @Test
    fun testTaskConditionsHaveValidZombieTypes() {
        // Generate a bounty
        val bounty = BountyGenerationService.generateInfectedBounty("test-player-123")
        
        // Valid zombie types
        val validZombieTypes = listOf(
            "zombie", "fast", "fat", "exploder", "spitter", "flaming", "tendrils", "boss"
        )
        
        // Verify each condition has valid zombie type and kills
        bounty.tasks.forEach { task ->
            assertTrue(task.conditions.isNotEmpty(), "Task should have at least one condition")
            assertTrue(task.conditions.size <= 3, "Task should have at most 3 conditions")
            
            task.conditions.forEach { condition ->
                assertTrue(validZombieTypes.contains(condition.zombieType),
                    "Condition zombie type '${condition.zombieType}' should be valid")
                assertTrue(condition.killsRequired > 0, 
                    "Kills required should be positive")
                assertEquals(0, condition.kills, 
                    "Initial kills should be 0")
            }
        }
    }
    
    @Test
    fun testKillsRequiredMatchZombieType() {
        // Generate multiple bounties to test range
        repeat(10) {
            val bounty = BountyGenerationService.generateInfectedBounty("test-player-$it")
            
            bounty.tasks.forEach { task ->
                task.conditions.forEach { condition ->
                    val kills = condition.killsRequired
                    
                    // Verify kills required is reasonable based on zombie type
                    when (condition.zombieType) {
                        "boss" -> assertTrue(kills in 1..2, 
                            "Boss kills should be 1-2, got $kills")
                        "exploder", "spitter", "flaming", "tendrils" -> 
                            assertTrue(kills in 5..14, 
                                "Special zombie kills should be 5-14, got $kills")
                        "fast", "fat" -> 
                            assertTrue(kills in 10..24, 
                                "Medium zombie kills should be 10-24, got $kills")
                        else -> 
                            assertTrue(kills in 15..34, 
                                "Regular zombie kills should be 15-34, got $kills")
                    }
                }
            }
        }
    }
    
    @Test
    fun testCalculateNextIssueTime() {
        val currentTime = System.currentTimeMillis()
        val nextIssueTime = BountyGenerationService.calculateNextIssueTime()
        
        // Verify next issue time is approximately 24 hours in the future
        val hourInMillis = 60 * 60 * 1000L
        val expectedNextIssue = currentTime + (24 * hourInMillis)
        
        // Allow 1 second variance for execution time
        assertTrue(nextIssueTime >= expectedNextIssue - 1000, 
            "Next issue time should be at least 24 hours in future")
        assertTrue(nextIssueTime <= expectedNextIssue + 1000, 
            "Next issue time should not be more than 24 hours + 1s in future")
    }
    
    @Test
    fun testMultipleBountiesAreUnique() {
        // Generate multiple bounties
        val bounty1 = BountyGenerationService.generateInfectedBounty("player1")
        val bounty2 = BountyGenerationService.generateInfectedBounty("player2")
        
        // Verify they have different IDs
        assertTrue(bounty1.id != bounty2.id, 
            "Different bounties should have different IDs")
    }
}
