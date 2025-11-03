package core.data

import core.data.assets.*
import core.data.parser.CostTableParser
import core.data.resources.*
import core.model.game.data.GameResources
import io.ktor.util.date.*
import utils.Emoji
import utils.Logger
import java.io.File
import java.util.zip.GZIPInputStream
import javax.xml.parsers.DocumentBuilderFactory
import kotlin.time.Duration.Companion.milliseconds

object GameDefinition {
    val itemsById = mutableMapOf<String, ItemResource>()
    val itemsByIdUppercased = mutableMapOf<String, ItemResource>()
    val itemsByType = mutableMapOf<String, MutableList<ItemResource>>()
    val itemsByLootable = mutableMapOf<String, MutableList<ItemResource>>()

    val buildingsById = mutableMapOf<String, BuildingResource>()
    val buildingsByType = mutableMapOf<String, MutableList<BuildingResource>>()

    val craftingRecipesById = mutableMapOf<String, CraftingResource>()
    val craftingRecipesByType = mutableMapOf<String, MutableList<CraftingResource>>()

    val skillsById = mutableMapOf<String, SkillResource>()

    val effectsById = mutableMapOf<String, EffectResource>()
    val effectTypes = mutableListOf<String>()

    val arenasById = mutableMapOf<String, core.model.game.data.arena.ArenaDefinition>()

    val config = GameConfig()
    var costTable = CostTable()

    fun initialize() {
        val resourcesToLoad = mapOf(
            "static/game/data/xml/config.xml.gz" to ConfigParser(),
            "static/game/data/xml/items.xml.gz" to ItemsParser(),
            "static/game/data/xml/buildings.xml.gz" to BuildingsParser(),
            "static/game/data/xml/crafting.xml.gz" to CraftingParser(),
            "static/game/data/xml/skills.xml.gz" to SkillsParser(),
            "static/game/data/xml/effects.xml.gz" to EffectsParser(),
            "static/game/data/xml/arenas.xml.gz" to ArenasParser()
        )

        for ((path, parser) in resourcesToLoad) {
            val start = getTimeMillis()
            val file = File(path)

            if (!file.exists()) {
                Logger.warn { "File not found: $path" }
                continue
            }

            GZIPInputStream(file.inputStream()).use {
                val document = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(it)
                parser.parse(document, this)
            }

            val end = getTimeMillis()
            val resName = path.removePrefix("static/game/data/xml/").removeSuffix(".gz")

            Logger.info { "📦 Finished parsing $resName in ${(end - start).milliseconds}" }
        }

        val costTableStart = getTimeMillis()
        costTable = CostTableParser.parse(File("static/data/cost_table.json"))
        val costTableEnd = getTimeMillis()
        Logger.info { "📦 Finished parsing cost_table.json in ${(costTableEnd - costTableStart).milliseconds}" }

        Logger.info("${Emoji.Gaming} Game resources loaded")
    }

    fun findItem(id: String): ItemResource? {
        return itemsById[id] ?: itemsByIdUppercased[id.uppercase()]
    }

    fun requireItem(idInXml: String): ItemResource {
        return requireNotNull(findItem(idInXml)) { "Items with ID in XML $idInXml is missing from index" }
    }

    fun isResourceItem(idInXml: String): Boolean {
        return requireItem(idInXml).type == "resource"
    }

    fun getMaxStackOfItem(idInXml: String): Int {
        val item = requireItem(idInXml)
        return item.stack
    }

    fun getResourceAmount(idInXml: String): GameResources? {
        val item = requireItem(idInXml)
        if (item.type != "resource") return null
        return item.resources
    }

    fun makeBuildingFromId(id: String): BuildingResource {
        return requireNotNull(buildingsById[id]) { "Building with ID $id is missing from index" }
    }

    fun findBuilding(id: String): BuildingResource? {
        return buildingsById[id]
    }

    fun requireBuilding(id: String): BuildingResource {
        return requireNotNull(findBuilding(id)) { "Building with ID $id is missing from index" }
    }

    fun findCraftingRecipe(id: String): CraftingResource? {
        return craftingRecipesById[id]
    }

    fun requireCraftingRecipe(id: String): CraftingResource {
        return requireNotNull(findCraftingRecipe(id)) { "Crafting recipe with ID $id is missing from index" }
    }

    fun findSkill(id: String): SkillResource? {
        return skillsById[id]
    }

    fun requireSkill(id: String): SkillResource {
        return requireNotNull(findSkill(id)) { "Skill with ID $id is missing from index" }
    }

    fun findEffect(id: String): EffectResource? {
        return effectsById[id]
    }

    fun requireEffect(id: String): EffectResource {
        return requireNotNull(findEffect(id)) { "Effect with ID $id is missing from index" }
    }
}

data class GameConfig(
    
    var baseReturnTime: Int = 75,
    var maxReturnTime: Int = 14400,
    var maxReturnTimePvp: Int = 7200,
    var minReturnTime: Int = 150,
    var minAutoReturnTime: Int = 600,
    var missionTime: Int = 420,
    var missionPvpTime: Int = 480,
    var missionDeployTime: Int = 180,
    var compoundAttackTime: Int = 30,

    var batchRecycleTimePerItem: Int = 1,
    var batchRecycleTimePerQty: Int = 5,
    var batchRecycleMaxItems: Int = 30,
    var batchRecycleMaxJobs: Int = 1,
    var batchRecycleCostPerMin: Double = 0.5,
    var batchRecycleMinCost: Int = 50,

    var recycleWoodMin: Int = 2,
    var recycleWoodMax: Int = 5,
    var recycleMetalMin: Int = 1,
    var recycleMetalMax: Int = 3,
    var recycleClothMin: Int = 1,
    var recycleClothMax: Int = 4,
    var recycleWaterMin: Int = 1,
    var recycleWaterMax: Int = 2,
    var recycleChancePerResource: Double = 0.3,

    var lootBoostFuelItems: Double = 3.0,
    var lootBoostJunkItems: Double = 0.8,
    var lootBoostBlueQuality: Double = 0.5,

    var storageCapacityDefault: Int = 100_000_000,

    var startingCash: Int = 100,
    var startingWood: Int = 300,
    var startingMetal: Int = 300,
    var startingCloth: Int = 300,
    var startingFood: Int = 25,
    var startingWater: Int = 25,
    var startingAmmunition: Int = 150,

    var adminCash: Int = 100000,
    var adminWood: Int = 99999,
    var adminMetal: Int = 99999,
    var adminCloth: Int = 99999,
    var adminFood: Int = 200,
    var adminWater: Int = 200,
    var adminAmmunition: Int = 99999,

    var survivorReassignTimePerLevel: Int = 1800,

    var baseZombieKillXp: Double = 0.93,
    var baseHumanKillXp: Int = 50,
    var baseSurvivorKillXp: Int = 50,
    var baseScavengeXp: Int = 2,
    var baseHealXp: Int = 5,

    var missionBaseXp: Int = 50,
    var missionZombieKillXp: Int = 5,
    var missionRunnerKillXp: Int = 10,
    var missionFattyKillXp: Int = 15,
    var missionBossKillXp: Int = 100,
    var missionMaxXp: Int = 1000,

    var injuryMinorRecoveryTime: Int = 43200,     
    var injuryModerateRecoveryTime: Int = 57600,  
    var injurySeriousRecoveryTime: Int = 172800,  
    var injurySevereRecoveryTime: Int = 345600,   
    var injuryCriticalRecoveryTime: Int = 518400, 

    var modRecycleMultiplier: Double = 0.2,
    var repairTimePerLevel: Int = 240,
    var repairTimeRound: Int = 300
)
