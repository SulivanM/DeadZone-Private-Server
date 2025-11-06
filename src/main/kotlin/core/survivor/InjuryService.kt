package core.survivor

import core.data.GameDefinition
import core.survivor.model.injury.Injury
import core.survivor.model.injury.InjuryCause
import core.survivor.model.injury.InjurySeverity
import dev.deadzone.core.model.game.data.TimerData
import io.ktor.util.date.*
import utils.UUID
import kotlin.random.Random
import kotlin.time.Duration.Companion.seconds

object InjuryService {
    
    
    private val injuryTypes = listOf(
        "fracture" to 500,
        "laceration" to 400,
        "burn" to 300,
        "infection" to 200,
        "bruise" to 600
    )
    
    
    private val injuryLocations = listOf(
        "skull", "arm", "leg", "torso", "hand", "foot"
    )
    
    
    
    private fun getSeverityConfigs() = mapOf(
        "minor" to Triple(GameDefinition.config.injuryMinorRecoveryTime, 0.1, -1.0),
        "moderate" to Triple(GameDefinition.config.injuryModerateRecoveryTime, 0.15, -6.0),
        "serious" to Triple(GameDefinition.config.injurySeriousRecoveryTime, 0.4, -10.0),
        "severe" to Triple(GameDefinition.config.injurySevereRecoveryTime, 0.5, -18.0),
        "critical" to Triple(GameDefinition.config.injuryCriticalRecoveryTime, 0.6, -25.0)
    )
    
    
    fun generateInjury(
        severityGroup: String,
        cause: String,
        force: Boolean = false,
        isCritical: Boolean = false
    ): Injury? {
        
        val severity = when {
            isCritical -> "critical"
            severityGroup == "minor" -> {
                if (Random.nextDouble() < 0.8) "minor" else "moderate"
            }
            severityGroup == "major" -> {
                val roll = Random.nextDouble()
                when {
                    roll < 0.5 -> "serious"
                    roll < 0.8 -> "severe"
                    else -> "critical"
                }
            }
            else -> "minor"
        }
        
        
        if (!force && Random.nextDouble() > 0.6) {
            return null 
        }
        
        
        val totalRarity = injuryTypes.sumOf { it.second }
        var roll = Random.nextInt(totalRarity)
        var selectedType = injuryTypes[0].first
        
        for ((type, rarity) in injuryTypes) {
            roll -= rarity
            if (roll < 0) {
                selectedType = type
                break
            }
        }
        
        
        val location = injuryLocations.random()

        val severityConfigs = getSeverityConfigs()
        val (timeSeconds, damage, morale) = severityConfigs[severity]
            ?: severityConfigs["minor"]!!
        
        
        val timer = TimerData(
            start = getTimeMillis(),
            length = timeSeconds.toLong(),
            data = mapOf(
                "type" to "injury",
                "severity" to severity
            )
        )
        
        return Injury(
            id = UUID.new(),
            type = selectedType,
            location = location,
            severity = severity,
            damage = damage,
            morale = morale,
            timer = timer
        )
    }
    
    
    fun isValidCause(cause: String): Boolean {
        return cause in listOf("unknown", "blunt", "sharp", "heat", "bullet", "illness")
    }
    
    
    fun isValidSeverityGroup(severityGroup: String): Boolean {
        return severityGroup in listOf("minor", "major")
    }
}
