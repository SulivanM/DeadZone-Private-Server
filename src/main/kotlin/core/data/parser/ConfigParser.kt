package core.data.assets

import core.data.GameDefinition
import org.w3c.dom.Document
import org.w3c.dom.Element

class ConfigParser() : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val root = doc.documentElement
        
        
        gameDefinition.config.baseReturnTime = getElementTextAsInt(root, "BASE_RETURN_TIME") ?: 75
        gameDefinition.config.maxReturnTime = getElementTextAsInt(root, "MAX_RETURN_TIME") ?: 14400
        gameDefinition.config.maxReturnTimePvp = getElementTextAsInt(root, "MAX_RETURN_TIME_PVP") ?: 7200
        gameDefinition.config.minReturnTime = getElementTextAsInt(root, "MIN_RETURN_TIME") ?: 150
        gameDefinition.config.minAutoReturnTime = getElementTextAsInt(root, "MIN_AUTO_RETURN_TIME") ?: 600
        gameDefinition.config.missionTime = getElementTextAsInt(root, "MISSION_TIME") ?: 420
        gameDefinition.config.missionPvpTime = getElementTextAsInt(root, "MISSION_PVP_TIME") ?: 480
        gameDefinition.config.missionDeployTime = getElementTextAsInt(root, "MISSION_DEPLOY_TIME") ?: 180
        
        
        gameDefinition.config.batchRecycleTimePerItem = getElementTextAsInt(root, "BATCH_RECYCLE_TIME_PER_ITEM") ?: 1
        gameDefinition.config.batchRecycleTimePerQty = getElementTextAsInt(root, "BATCH_RECYCLE_TIME_PER_QTY") ?: 5
        gameDefinition.config.batchRecycleMaxItems = getElementTextAsInt(root, "BATCH_RECYCLE_MAX_ITEMS") ?: 30
        gameDefinition.config.batchRecycleMaxJobs = getElementTextAsInt(root, "BATCH_RECYCLE_MAX_JOBS") ?: 1
        
        
        gameDefinition.config.survivorReassignTimePerLevel = getElementTextAsInt(root, "SURVIVOR_REASSIGN_TIME_PER_LEVEL") ?: 1800
        
        
        gameDefinition.config.baseZombieKillXp = getElementTextAsDouble(root, "BASE_ZOMBIE_KILL_XP") ?: 0.93
        gameDefinition.config.baseHumanKillXp = getElementTextAsInt(root, "BASE_HUMAN_KILL_XP") ?: 50
        gameDefinition.config.baseSurvivorKillXp = getElementTextAsInt(root, "BASE_SURVIVOR_KILL_XP") ?: 50
        gameDefinition.config.baseScavengeXp = getElementTextAsInt(root, "BASE_SCAVENGE_XP") ?: 2
        gameDefinition.config.baseHealXp = getElementTextAsInt(root, "BASE_HEAL_XP") ?: 5

        gameDefinition.config.missionBaseXp = getElementTextAsInt(root, "MISSION_BASE_XP") ?: 50
        gameDefinition.config.missionZombieKillXp = getElementTextAsInt(root, "MISSION_ZOMBIE_KILL_XP") ?: 5
        gameDefinition.config.missionRunnerKillXp = getElementTextAsInt(root, "MISSION_RUNNER_KILL_XP") ?: 10
        gameDefinition.config.missionFattyKillXp = getElementTextAsInt(root, "MISSION_FATTY_KILL_XP") ?: 15
        gameDefinition.config.missionBossKillXp = getElementTextAsInt(root, "MISSION_BOSS_KILL_XP") ?: 100
        gameDefinition.config.missionMaxXp = getElementTextAsInt(root, "MISSION_MAX_XP") ?: 1000

        gameDefinition.config.injuryMinorRecoveryTime = getElementTextAsInt(root, "INJURY_MINOR_RECOVERY_TIME") ?: 43200
        gameDefinition.config.injuryModerateRecoveryTime = getElementTextAsInt(root, "INJURY_MODERATE_RECOVERY_TIME") ?: 57600
        gameDefinition.config.injurySeriousRecoveryTime = getElementTextAsInt(root, "INJURY_SERIOUS_RECOVERY_TIME") ?: 172800
        gameDefinition.config.injurySevereRecoveryTime = getElementTextAsInt(root, "INJURY_SEVERE_RECOVERY_TIME") ?: 345600
        gameDefinition.config.injuryCriticalRecoveryTime = getElementTextAsInt(root, "INJURY_CRITICAL_RECOVERY_TIME") ?: 518400

        gameDefinition.config.modRecycleMultiplier = getElementTextAsDouble(root, "MOD_RECYCLE_MULTIPLIER") ?: 0.2
        gameDefinition.config.repairTimePerLevel = getElementTextAsInt(root, "REPAIR_TIME_PER_LEVEL") ?: 240
        gameDefinition.config.repairTimeRound = getElementTextAsInt(root, "REPAIR_TIME_ROUND") ?: 300
    }
    
    private fun getElementTextAsInt(root: Element, tagName: String): Int? {
        val elements = root.getElementsByTagName(tagName)
        if (elements.length == 0) return null
        val element = elements.item(0) as? Element ?: return null
        return element.textContent.trim().toIntOrNull()
    }
    
    private fun getElementTextAsDouble(root: Element, tagName: String): Double? {
        val elements = root.getElementsByTagName(tagName)
        if (elements.length == 0) return null
        val element = elements.item(0) as? Element ?: return null
        return element.textContent.trim().toDoubleOrNull()
    }
}
