package core.data

import core.data.assets.*
import core.model.game.data.GameResources
import io.ktor.util.date.*
import org.w3c.dom.Element
import utils.Emoji
import utils.Logger
import java.io.File
import java.util.zip.GZIPInputStream
import javax.xml.parsers.DocumentBuilderFactory
import kotlin.time.Duration.Companion.milliseconds

/**
 * Global registry that holds game data and config from parsing the game XML resources.
 *
 * You will need to read the XML resources in data/xml/. This is to sync with client-side data.
 * Sometimes the client-side does not send every data (like what zombie it request or what loot it expects)
 * This is because it expects the server to handle it, including data lookup to those XMLs.
 *
 * - For example, items.xml read includes initializing in-memory index such as itemsById, itemsByType, allowing easy retrieval.
 * - zombie.xml may includes zombies of same type with different level (use this to choose which zombie to spawn depend on area level).
 * - zombie.xml also have rarity, use this to determine the rarity of spawning that zombie (Yes we need zombie system just like we have the loot system).
 * - For buildings.xml maybe you will need the data for some buildings like production (reading the prod element) to see its production rate, etc.
 * - badwords.xml contains useful badword utility. We may use it as verification (not very important here).
 * - I haven't checked other.
 *
 * VERY IMPORTANT: there is confusion around id, type for all XML resources.
 * - in the server, id is treated as unique identifier,
 * type as the 'id' in the XML,
 * and server does not store extra "type" which correspond to the 'type' in XML.
 * - in the game, lookup to XML is done in syntax like @id == type. This means that the id (at) XML must be equal to type sent from server.
 * - For type in XML lookup, you can make similar server index like itemsByType
 */
object GameDefinition {
    val itemsById = mutableMapOf<String, ItemResource>()
    val itemsByIdUppercased = mutableMapOf<String, ItemResource>()
    val itemsByType = mutableMapOf<String, MutableList<ItemResource>>()
    val itemsByLootable = mutableMapOf<String, MutableList<ItemResource>>()

    fun initialize() {
        val resourcesToLoad = mapOf(
            "static/game/data/xml/alliances.xml.gz" to AlliancesParser(),
            "static/game/data/xml/arenas.xml.gz" to ArenasParser(),
            "static/game/data/xml/attire.xml.gz" to AttireParser(),
            "static/game/data/xml/badwords.xml.gz" to BadwordsParser(),
            "static/game/data/xml/buildings.xml.gz" to BuildingsParser(),
            "static/game/data/xml/config.xml.gz" to ConfigParser(),
            "static/game/data/xml/crafting.xml.gz" to CraftingParser(),
            "static/game/data/xml/effects.xml.gz" to EffectsParser(),
            "static/game/data/xml/humanenemies.xml.gz" to HumanEnemiesParser(),
            "static/game/data/xml/injury.xml.gz" to InjuryParser(),
            "static/game/data/xml/itemmods.xml.gz" to ItemModsParser(),
            "static/game/data/xml/items.xml.gz" to ItemsParser(),
            "static/game/data/xml/quests.xml.gz" to QuestsGlobalParser(),
            "static/game/data/xml/quests_global.xml.gz" to RaidsParser(),
            "static/game/data/xml/raids.xml.gz" to SkillsParser(),
            "static/game/data/xml/skills.xml.gz" to StreetStructsParser(),
            "static/game/data/xml/streetstructs.xml.gz" to SurvivorParser(),
            "static/game/data/xml/survivor.xml.gz" to VehicleNamesParser(),
            "static/game/data/xml/vehiclenames.xml.gz" to ZombiesParser()
        )

        for ((path, parser) in resourcesToLoad) {
            val start = getTimeMillis()
            val file = File(path)

            if (path != "static/game/data/xml/items.xml.gz") continue // only parse items for now

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

    /**
     * Find an item resource by ID, preferring exact match first.
     *
     * It is preferred to use this method to find an item resource.
     * The game is known to be inconsistent for referencing item ID.
     * Sometimes, it sends uppercased ID although items.xml definition is case-sensitive.
     */
    fun findItem(id: String): ItemResource? {
        return itemsById[id] ?: itemsByIdUppercased[id.uppercase()]
    }

    fun requireItem(idInXml: String): ItemResource {
        return requireNotNull(findItem(idInXml)) { "Items with ID in XML $idInXml is missing from index" }
    }

    fun isResourceItem(idInXml: String): Boolean {
        return requireItem(idInXml).type == "resource"
    }

    /**
     * Get max stack of certain item ID
     *
     * @return `Int` the number of maximum stack,
     * 1 as default value if stack amount is not listed in the XML.
     */
    fun getMaxStackOfItem(idInXml: String): Int {
        val item = requireItem(idInXml)
        val stackNode = item.element.getElementsByTagName("stack")
        return (stackNode.item(0) as? Element)?.textContent?.trim()?.toIntOrNull() ?: 1
    }

    /**
     * Get the resource amount of a certain item ID.
     *
     * @return [GameResources] object with resource amount set according to the item.
     * Return `null` if the ID is not a resource type of item.
     */
    fun getResourceAmount(idInXml: String): GameResources? {
        val item = requireItem(idInXml)
        if (item.type != "resource") return null

        val resourceMap = mutableMapOf<String, Int>()

        val resNodes = item.element.getElementsByTagName("res")
        for (i in 0 until resNodes.length) {
            val resItemsNodes = resNodes.item(i) as? Element ?: continue
            val itemId = resItemsNodes.getAttribute("id")
            val amount = resItemsNodes.textContent.trim().toIntOrNull() ?: 0
            resourceMap[itemId] = resourceMap.getOrDefault(itemId, 0) + amount
        }

        return GameResources(
            wood = resourceMap["wood"] ?: 0,
            metal = resourceMap["metal"] ?: 0,
            cloth = resourceMap["cloth"] ?: 0,
            water = resourceMap["water"] ?: 0,
            food = resourceMap["food"] ?: 0,
            ammunition = resourceMap["ammunition"] ?: 0,
            cash = resourceMap["cash"] ?: 0
        )
    }
}
