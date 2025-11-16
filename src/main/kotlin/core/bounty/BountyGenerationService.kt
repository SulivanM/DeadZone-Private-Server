package core.bounty

import core.model.game.data.bounty.InfectedBounty
import core.model.game.data.bounty.InfectedBountyTask
import core.model.game.data.bounty.InfectedBountyTaskCondition
import java.util.UUID
import kotlin.random.Random

/**
 * Service for generating infected bounties
 */
object BountyGenerationService {
    
    // List of available suburbs for bounties
    private val suburbs = listOf(
        "Dartside", "Doddingston", "Greyside_NW", "Greyside_NE", "Greyside_SW", "Greyside_SE",
        "Nastya's Holdout", "Secronom", "Wasteland"
    )
    
    // List of zombie types that can be targets
    private val zombieTypes = listOf(
        "zombie", "fast", "fat", "exploder", "spitter", "flaming", "tendrils", "boss"
    )
    
    /**
     * Generates a new infected bounty with random tasks and conditions
     */
    fun generateInfectedBounty(playerId: String): InfectedBounty {
        val bountyId = UUID.randomUUID().toString()
        val issueTime = System.currentTimeMillis()
        
        // Generate 1-3 random tasks
        val numTasks = Random.nextInt(1, 4)
        val selectedSuburbs = suburbs.shuffled().take(numTasks)
        
        val tasks = selectedSuburbs.map { suburb ->
            generateTask(suburb)
        }
        
        return InfectedBounty(
            id = bountyId,
            completed = false,
            abandoned = false,
            viewed = false,
            rewardItemId = "",  // Will be set when bounty is completed
            issueTime = issueTime,
            tasks = tasks
        )
    }
    
    /**
     * Generates a single task for a suburb
     */
    private fun generateTask(suburb: String): InfectedBountyTask {
        // Generate 1-3 conditions per task
        val numConditions = Random.nextInt(1, 4)
        val selectedZombieTypes = zombieTypes.shuffled().take(numConditions)
        
        val conditions = selectedZombieTypes.map { zombieType ->
            generateCondition(suburb, zombieType)
        }
        
        return InfectedBountyTask(
            suburb = suburb,
            conditions = conditions
        )
    }
    
    /**
     * Generates a single condition for killing zombies
     */
    private fun generateCondition(suburb: String, zombieType: String): InfectedBountyTaskCondition {
        // Determine kills required based on zombie type
        val killsRequired = when (zombieType) {
            "boss" -> Random.nextInt(1, 3)  // 1-2 bosses
            "exploder", "spitter", "flaming", "tendrils" -> Random.nextInt(5, 15)  // 5-14 special zombies
            "fast", "fat" -> Random.nextInt(10, 25)  // 10-24 medium zombies
            else -> Random.nextInt(15, 35)  // 15-34 regular zombies
        }
        
        return InfectedBountyTaskCondition(
            zombieType = zombieType,
            killsRequired = killsRequired,
            kills = 0  // Start with 0 kills
        )
    }
    
    /**
     * Calculates the next bounty issue time (24 hours from now)
     */
    fun calculateNextIssueTime(): Long {
        return System.currentTimeMillis() + (24 * 60 * 60 * 1000)  // 24 hours
    }
}
