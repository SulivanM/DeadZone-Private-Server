package core.data.assets

import core.data.GameDefinition
import org.w3c.dom.Document
import org.w3c.dom.Element

data class ItemResource(
    val idInXML: String, // id in xml
    val type: String,
    val element: Element
) {
    override fun toString(): String {
        return "ItemResource(idInXML=$idInXML, type=$type)"
    }
}

class ItemsParser() : GameResourcesParser {
    override fun parse(doc: Document, gameDefinition: GameDefinition) {
        val items = doc.getElementsByTagName("item")

        for (i in 0 until items.length) {
            val itemNode = items.item(i) as? Element ?: continue
            val itemId = itemNode.getAttribute("id").takeIf { it != "" } ?: continue
            val itemType = itemNode.getAttribute("type").takeIf { it != "" } ?: continue
            val itemLocs = itemNode.getAttribute("locs").takeIf { it != "" }

            val res = ItemResource(itemId, itemType, itemNode)

            gameDefinition.itemsById.putIfAbsent(itemId, res)
            gameDefinition.itemsByIdUppercased.putIfAbsent(itemId.uppercase(), res)
            gameDefinition.itemsByType.computeIfAbsent(itemId) { mutableListOf() }.add(res)
            if (itemLocs?.isNotEmpty() ?: false) {
                val locList = itemLocs.split(',').map { it.trim() }
                for (loc in locList) {
                    gameDefinition.itemsByLootable.computeIfAbsent(loc) { mutableListOf() }.add(res)
                }
            }
        }
    }
}
