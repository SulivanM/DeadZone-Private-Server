package core.items

import core.data.GameDefinition
import core.data.assets.ItemResource
import core.items.model.Item
import core.items.model.ItemQualityType
import utils.UUID
import org.w3c.dom.Element

object ItemFactory {
    fun getRandomItem(): Item {
        return createItemFromResource(res = GameDefinition.itemsById.values.random())
    }

    fun createItemFromId(itemId: String = UUID.new(), idInXML: String): Item {
        val res = GameDefinition.findItem(idInXML)
            ?: throw IllegalArgumentException("Failed creating Item id=$itemId from xml id=$idInXML (xml id not found)")
        return createItemFromResource(itemId, res)
    }

    fun createItemFromResource(itemId: String = UUID.new(), res: ItemResource): Item {
        val baseItem = Item(
            id = itemId,
            type = res.idInXML,
            quality = ItemQualityType.fromString(res.element.getAttribute("quality"))
        )

        when (res.type) {
            "gear" -> parseGear(res.element, baseItem)
            "weapon" -> parseWeapon(res.element, baseItem)
            "clothing" -> parseClothing(res.element, baseItem)
            // and many more...
        }

        return baseItem
    }

    // these should modify the base item as needed
    // currently does nothing as we are not sure the detailed traits of each item types
    private fun parseGear(element: Element, baseItem: Item) {}
    private fun parseWeapon(element: Element, baseItem: Item) {}
    private fun parseClothing(element: Element, baseItem: Item) {}
}
