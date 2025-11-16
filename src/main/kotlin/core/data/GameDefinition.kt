package core.data

import core.data.assets.*
import core.data.resources.*
import core.model.game.data.GameResources
import io.ktor.util.date.*
import common.Emoji
import common.Logger
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

    val questTypes = mutableListOf<String>()
    val questsById = mutableMapOf<String, QuestDefinition>()
    val questsByLevel = mutableMapOf<Int, MutableList<QuestDefinition>>()
    val achievementsById = mutableMapOf<String, QuestDefinition>()
    val repeatableAchievements = mutableMapOf<String, AchievementDefinition>()
    val dynamicQuestConfigs = mutableListOf<DynamicQuestConfig>()

    // New XML parsers data
    var vehicleNames: VehicleNamesResource? = null
    var badwords: BadwordsResource? = null
    var config: ConfigResource? = null
    val survivorArrivals = mutableListOf<SurvivorArrivalRequirement>()
    val itemModsById = mutableMapOf<String, ItemModResource>()
    var zombieSounds: ZombieSounds? = null
    var zombieLimits: ZombieLimits? = null
    val zombieWeaponsById = mutableMapOf<String, ZombieResource>()
    val severityConfigs = mutableListOf<SeverityConfig>()
    val injuriesByType = mutableMapOf<String, InjuryResource>()
    val humanEnemyWeaponsById = mutableMapOf<String, HumanEnemyWeapon>()
    val humanEnemiesById = mutableMapOf<String, HumanEnemyResource>()
    val arenasById = mutableMapOf<String, ArenaResource>()
    val raidsById = mutableMapOf<String, RaidResource>()
    val voicesById = mutableMapOf<String, VoiceResource>()
    val hairTexturesById = mutableMapOf<String, HairTextureResource>()
    val attireById = mutableMapOf<String, AttireResource>()
    var alliance: AllianceResource? = null
    val globalQuestsById = mutableMapOf<String, GlobalQuestResource>()
    var globalQuestGracePeriod: Int? = null

    fun initialize() {
        val resourcesToLoad = mapOf(
            // Critical game data - load first
            "static/game/data/xml/config.xml.gz" to ConfigParser(),

            // Core game resources
            "static/game/data/xml/items.xml.gz" to ItemsParser(),
            "static/game/data/xml/buildings.xml.gz" to BuildingsParser(),
            "static/game/data/xml/crafting.xml.gz" to CraftingParser(),
            "static/game/data/xml/skills.xml.gz" to SkillsParser(),
            "static/game/data/xml/effects.xml.gz" to EffectsParser(),
            "static/game/data/xml/quests.xml.gz" to QuestsParser(),

            // Item modifications and appearance
            "static/game/data/xml/itemmods.xml.gz" to ItemModsParser(),
            "static/game/data/xml/attire.xml.gz" to AttireParser(),

            // Survivor and injury systems
            "static/game/data/xml/survivor.xml.gz" to SurvivorParser(),
            "static/game/data/xml/injury.xml.gz" to InjuryParser(),

            // Enemy systems
            "static/game/data/xml/zombie.xml.gz" to ZombiesParser(),
            "static/game/data/xml/humanenemies.xml.gz" to HumanEnemiesParser(),

            // Multiplayer and competitive content
            "static/game/data/xml/arenas.xml.gz" to ArenasParser(),
            "static/game/data/xml/raids.xml.gz" to RaidsParser(),
            "static/game/data/xml/alliances.xml.gz" to AlliancesParser(),
            "static/game/data/xml/quests_global.xml.gz" to QuestsGlobalParser(),

            // Utility systems
            "static/game/data/xml/vehiclenames.xml.gz" to VehicleNamesParser(),
            "static/game/data/xml/badwords.xml.gz" to BadwordsParser()
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

    fun findQuest(id: String): QuestDefinition? {
        return questsById[id]
    }

    fun requireQuest(id: String): QuestDefinition {
        return requireNotNull(findQuest(id)) { "Quest with ID $id is missing from index" }
    }

    fun findAchievement(id: String): QuestDefinition? {
        return achievementsById[id]
    }

    fun requireAchievement(id: String): QuestDefinition {
        return requireNotNull(findAchievement(id)) { "Achievement with ID $id is missing from index" }
    }

    fun findQuestOrAchievement(id: String): QuestDefinition? {
        return findQuest(id) ?: findAchievement(id)
    }
}
