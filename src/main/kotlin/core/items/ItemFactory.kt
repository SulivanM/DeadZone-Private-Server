package core.items

import core.data.GameDefinition
import core.data.resources.ItemResource
import core.items.model.Item
import core.items.model.ItemQualityType
import common.UUID

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
            type = res.id,
            quality = ItemQualityType.fromString(res.quality ?: "")
        )

        when (res.type) {
            "gear" -> parseGear(res, baseItem)
            "weapon" -> parseWeapon(res, baseItem)
            "clothing" -> parseClothing(res, baseItem)
        }

        return baseItem
    }

    private fun parseGear(res: ItemResource, baseItem: Item) {}
    private fun parseWeapon(res: ItemResource, baseItem: Item) {}
    private fun parseClothing(res: ItemResource, baseItem: Item) {}
}
