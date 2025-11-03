package core.mission

import core.data.resources.ItemResource
import core.data.GameDefinition
import core.mission.model.LootContent
import core.mission.model.LootParameter
import utils.UUID
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
    "island", "firstaid", "anything", "zmas", "tutorialfuel"
)

class LootService(
    private val sceneXML: String,
    private val parameter: LootParameter
) {
    val cumulativeLootsPerLoc: MutableMap<String, TreeMap<Double, LootContent>> = mutableMapOf()
    val totalWeightPerLoc: MutableMap<String, Double> = mutableMapOf()
    val insertedLoots: MutableList<LootContent> = mutableListOf()

    init {
        buildIndexOfLootableItems()
    }

    private fun buildIndexOfLootableItems() {
        ALL_LOCS.forEach { loc ->
            val lootableInLoc = GameDefinition.itemsByLootable[loc] ?: emptyList()
            
            
            val treeMap = TreeMap<Double, LootContent>()
            var cumulativeWeight = 0.0

            loop@ for (item in lootableInLoc) {
                val specialItemsKeyword = listOf(
                    "halloween", "spooky", "pumpkin", "ghost", "witch",
                    "christmas", "winter", "snow", "xmas", "santa", "holiday",
                    "easter", "bunny", "egg",
                    "valentine", "love", "heart",
                    "summer", "beach", "sun", "vacation",
                    "autumn", "fall", "harvest",
                    "spring", "blossom",
                    "4july", "july", "independence", "firework",
                    "birthday", "anniversary", "celebration", "cake",
                    "newyear", "ny", "countdown",
                    "thanksgiving", "turkey", "feast",
                    "event", "limited", "special", "exclusive", "festive",
                    "cache", "box", "gacha", "crate"
                )

                val isEventItem = specialItemsKeyword.any { keyword ->
                    item.id.contains(keyword, ignoreCase = true)
                }

                if (isEventItem) continue

                val lvlMin = item.levelMin ?: 0
                val lvlMax = item.levelMax ?: Int.MAX_VALUE
                if (parameter.areaLevel !in (lvlMin..lvlMax)) continue

                val rarity = item.rarity?.toInt() ?: 1
                val type = item.type
                val quality = item.quality ?: ""

                val baseWeight = parameter.itemWeightOverrides[item.id]
                    ?: (parameter.baseWeight / rarity.toDouble())

                val itemBoost = parameter.specificItemBoost[item.id] ?: 0.0
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

    fun insertLoots(): Pair<String, List<LootContent>> {
        val docBuilder: DocumentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
        val doc: Document = docBuilder.parse(InputSource(StringReader(sceneXML)))

        val eList = doc.getElementsByTagName("e")
        for (i in 0 until eList.length) {
            val eNode = eList.item(i) as? Element ?: continue

            val optNode = eNode.getElementsByTagName("opt").item(0) as? Element ?: continue
            val srchNode = optNode.getElementsByTagName("srch").item(0) ?: continue

            val hasItms = (0 until eNode.childNodes.length)
                .map { eNode.childNodes.item(it) }
                .any { it is Element && it.tagName == "itms" }

            if (!hasItms) {
                val itmsElement = doc.createElement("itms")

                val loots = getRollsFromLocs(srchNode.textContent.split(","))
                for ((lootId, type, q) in loots) {
                    val itm = doc.createElement("itm")
                    itm.setAttribute("id", lootId)
                    itm.setAttribute("type", type)
                    itm.setAttribute("q", q.toString())
                    itmsElement.appendChild(itm)
                }

                insertedLoots.addAll(loots)
                eNode.appendChild(itmsElement)
            }
        }

        val transformer = TransformerFactory.newInstance().newTransformer().apply {
            setOutputProperty(OutputKeys.INDENT, "yes")
            setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2")
        }

        val writer = StringWriter()
        transformer.transform(DOMSource(doc), StreamResult(writer))
        return writer.toString() to insertedLoots
    }

    private fun getRollsFromLocs(locs: List<String>): List<LootContent> {
        
        val lootsAmount = (0..6).random()
        val lootResults: MutableList<LootContent> = mutableListOf()

        val availableLocs = locs.filter { cumulativeLootsPerLoc.containsKey(it) }
        
        if (availableLocs.isEmpty()) {
            return emptyList()
        }

        val shuffledLocs = availableLocs.shuffled()
        var i = 0

        val maxAttempts = lootsAmount * shuffledLocs.size + 10

        while (lootResults.size < lootsAmount && i < maxAttempts) {
            val loc = shuffledLocs[i % shuffledLocs.size]
            weightedRandomTree(loc)?.let { lootResults.add(it) }
            i += 1
        }

        return lootResults
    }

    private fun weightedRandomTree(loc: String): LootContent? {
        
        
        
        
        val possibleLoots = cumulativeLootsPerLoc[loc] ?: return null
        val totalWeight = totalWeightPerLoc[loc] ?: return null
        val roll = Random.nextDouble(0.0, totalWeight)
        return possibleLoots.ceilingEntry(roll)?.value
    }

    private fun createLootContent(res: ItemResource): LootContent {
        val qntMin = res.quantityMin ?: 1
        val qntMax = res.quantityMax ?: 1
        val min = minOf(qntMin, qntMax)
        val max = maxOf(qntMin, qntMax)
        val qty = (min..max).random()

        return LootContent(
            lootId = UUID.new(),
            itemIdInXML = res.id,
            quantity = qty,
        )
    }
}
