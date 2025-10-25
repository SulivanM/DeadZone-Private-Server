package core.data

import core.data.assets.*
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

    fun initialize() {
        val resourcesToLoad = mapOf(
            "static/game/data/xml/items.xml.gz" to ItemsParser(),
            "static/game/data/xml/buildings.xml.gz" to BuildingsParser(),
            "static/game/data/xml/crafting.xml.gz" to CraftingParser(),
            "static/game/data/xml/skills.xml.gz" to SkillsParser(),
            "static/game/data/xml/effects.xml.gz" to EffectsParser()
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
}
