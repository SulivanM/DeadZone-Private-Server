package dev.deadzone.core.mission

import dev.deadzone.core.data.assets.ItemResource
import dev.deadzone.context.GlobalContext
import dev.deadzone.core.data.GameDefinitions
import dev.deadzone.core.mission.model.LootContent
import dev.deadzone.core.mission.model.LootParameter
import dev.deadzone.utils.UUID
import org.w3c.dom.Document
import org.w3c.dom.Element
import java.io.StringReader
import java.io.StringWriter
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.OutputKeys
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult
import javax.xml.parsers.DocumentBuilder
import org.xml.sax.InputSource
import java.util.TreeMap
import kotlin.random.Random

val ALL_LOCS = listOf(
    "crafting", "backpack", "kitchen", "lounge", "bedroom", "bathroom",
    "random", "office", "store", "military", "weapon", "resource", "police",
    "gear", "tutorial", "fuel", "food", "fridge", "water", "vending", "car",
    "body", "basement", "ammo", "wood", "metal", "cloth", "comms", "hospital",
    "island", "firstaid"
) // + the tutorial convenience store (tutorialfuel)

class LootService(
    private val gameDefinitions: GameDefinitions = GlobalContext.gameDefinitions,
    private val sceneXML: String,
    private val parameter: LootParameter
) {
    val cumulativeLootsPerLoc: MutableMap<String, TreeMap<Double, LootContent>> = mutableMapOf()
    val totalWeightPerLoc: MutableMap<String, Double> = mutableMapOf()
    val insertedLoots: MutableList<LootContent> = mutableListOf()
    val itemsLootedByPlayer: MutableList<LootContent> = mutableListOf()

    init {
        buildIndexOfLootableItems()
    }

    private fun buildIndexOfLootableItems() {
        ALL_LOCS.forEach { loc ->
            val lootableInLoc = gameDefinitions.itemsByLootable[loc] ?: emptyList()
            // create a binary search tree whose key is cumulative weight and value is the loot
            // this will allow us to quickly search for an item based on a rolled double value just by seeing the cumulative weight
            val treeMap = TreeMap<Double, LootContent>()
            var cumulativeWeight = 0.0

            loop@ for (item in lootableInLoc) {
                val specialItemsKeyword = listOf(
                    // Seasonal & Holidays
                    "halloween", "spooky", "pumpkin", "ghost", "witch",
                    "christmas", "winter", "snow", "xmas", "santa", "holiday",
                    "easter", "bunny", "egg",
                    "valentine", "love", "heart",
                    "summer", "beach", "sun", "vacation",
                    "autumn", "fall", "harvest",
                    "spring", "blossom",

                    // National Days & Special Events
                    "4july", "july", "independence", "firework",
                    "birthday", "anniversary", "celebration", "cake",
                    "newyear", "ny", "countdown",
                    "thanksgiving", "turkey", "feast",

                    // Game-specific Events
                    "event", "limited", "special", "exclusive", "festive",

                    // Crate related
                    "cache", "box", "gacha", "crate"
                )

                // discard special items
                val isEventItem = specialItemsKeyword.any { keyword ->
                    item.idInXML.contains(keyword, ignoreCase = true)
                }

                if (isEventItem) continue

                // only pick items which level range contain areaLevel
                val lvlMin = item.element.getElementsByTagName("lvl_min").item(0)?.textContent?.toIntOrNull() ?: 0
                val lvlMax = item.element.getElementsByTagName("lvl_max").item(0)?.textContent?.toIntOrNull()
                    ?: Int.MAX_VALUE
                if (parameter.areaLevel !in (lvlMin..lvlMax)) continue

                val rarity = item.element.getAttribute("rarity").toIntOrNull() ?: 1
                val type = item.element.getAttribute("type")
                val quality = item.element.getAttribute("quality")

                val baseWeight = parameter.itemWeightOverrides[item.idInXML]
                    ?: (parameter.baseWeight / rarity.toDouble())

                // e.g., +0.2 means +20%
                val itemBoost = parameter.specificItemBoost[item.idInXML] ?: 0.0
                val typeBoost = parameter.itemTypeBoost[type] ?: 0.0
                val qualityBoost = parameter.itemQualityBoost[quality] ?: 0.0

                val totalMultiplier = (1.0 + itemBoost) * (1.0 + typeBoost) * (1.0 + qualityBoost)

                val finalWeight = (baseWeight * totalMultiplier).coerceAtLeast(0.0001)

                cumulativeWeight += finalWeight
                treeMap[cumulativeWeight] = createLootContent(item)
            }

            if (treeMap.isNotEmpty()) {
                cumulativeLootsPerLoc[loc] = treeMap
                totalWeightPerLoc[loc] = cumulativeWeight
            }
        }
    }

    fun insertLoots(): String {
        val docBuilder: DocumentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
        val doc: Document = docBuilder.parse(InputSource(StringReader(sceneXML)))

        val eList = doc.getElementsByTagName("e")
        for (i in 0 until eList.length) {
            val eNode = eList.item(i) as? Element ?: continue

            val optNode = eNode.getElementsByTagName("opt").item(0) as? Element ?: continue
            val srchNode = optNode.getElementsByTagName("srch").item(0) ?: continue

            // skip if the corresponding node has a predefined itms
            val hasItms = (0 until eNode.childNodes.length)
                .map { eNode.childNodes.item(it) }
                .any { it is Element && it.tagName == "itms" }

            if (!hasItms) {
                val itmsElement = doc.createElement("itms")

                val loots = getRollsFromLocs(srchNode.textContent.split(","))
                for ((id, type, q) in loots) {
                    val itm = doc.createElement("itm")
                    itm.setAttribute("id", id)
                    itm.setAttribute("type", type)
                    itm.setAttribute("q", q.toString())
                    itmsElement.appendChild(itm)
                }

                insertedLoots.addAll(loots)
                eNode.appendChild(itmsElement)
            }
        }

        // Transform back to string
        val transformer = TransformerFactory.newInstance().newTransformer().apply {
            setOutputProperty(OutputKeys.INDENT, "yes")
            setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2")
        }

        val writer = StringWriter()
        transformer.transform(DOMSource(doc), StreamResult(writer))
        return writer.toString()
    }

    private fun getRollsFromLocs(locs: List<String>): List<LootContent> {
        // roll 0-6 items per container
        val lootsAmount = (0..6).random()
        val lootResults: MutableList<LootContent> = mutableListOf()

        // shuffle the list of locs, and pick one item per loc
        // go back to start if still need more item
        val shuffledLocs = locs.shuffled()
        var i = 0

        while (lootResults.size < lootsAmount) {
            val loc = shuffledLocs[i % shuffledLocs.size]
            weightedRandomTree(loc)?.let { lootResults.add(it) }
            i += 1
        }

        return lootResults
    }

    private fun weightedRandomTree(loc: String): LootContent? {
        // use RNG to roll a double value within the total weight of a loc
        // quickly find the loot with cumulative weight lower or equal than the roll
        // e.g., for cumulative weight [1.5, 2.0, 3.0], or [0.0-1.5, 1.5-2.0, 2.0-3.0]
        // if roll is 1.4, pick the first
        val possibleLoots = cumulativeLootsPerLoc[loc] ?: return null
        val totalWeight = totalWeightPerLoc[loc] ?: return null
        val roll = Random.nextDouble(0.0, totalWeight)
        return possibleLoots.ceilingEntry(roll)?.value
    }

    private fun createLootContent(res: ItemResource): LootContent {
        val element = res.element
        val qntMin = element.getElementsByTagName("qnt_min").item(0)?.textContent?.toIntOrNull() ?: 1
        val qntMax = element.getElementsByTagName("qnt_max").item(0)?.textContent?.toIntOrNull() ?: 1
        val min = minOf(qntMin, qntMax)
        val max = maxOf(qntMin, qntMax)
        val qty = (min..max).random()
        // may want to set quantity depending on item type
        // i.e., weapon, schematics, is limited to 1 but junk items can be 5

        return LootContent(
            itemId = UUID.new(),
            itemIdInXML = res.idInXML,
            quantity = qty,
        )
    }
}
