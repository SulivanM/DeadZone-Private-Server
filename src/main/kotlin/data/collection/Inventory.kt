package data.collection

import core.data.AdminData
import core.data.GameDefinitions
import core.items.ItemFactory
import core.items.model.Item
import core.items.model.combineItems
import kotlinx.serialization.Serializable

/**
 * Inventory table
 */
@Serializable
data class Inventory(
    val playerId: String, // reference to UserDocument
    val inventory: List<Item> = emptyList(),
    val schematics: ByteArray = byteArrayOf(),  // see line 643 of Inventory.as
) {
    companion object {
        fun admin(): Inventory {
            val items = listOf(
                ItemFactory.createItemFromId(idInXML = "crate-tutorial"),
                ItemFactory.createItemFromId(idInXML = "crate-tutorial"),
                ItemFactory.createItemFromId(idInXML = "crate-tutorial"),
                ItemFactory.createItemFromId(idInXML = "crate-tutorial"),
                ItemFactory.createItemFromId(idInXML = "crate-tutorial"),
                ItemFactory.createItemFromId(idInXML = "crate-tutorial"),
                ItemFactory.createItemFromId(idInXML = "crate-tutorial"),
                ItemFactory.createItemFromId(idInXML = "crate-tutorial"),
                ItemFactory.createItemFromId(idInXML = "crate-tutorial"),
                ItemFactory.createItemFromId(idInXML = "crate-tutorial"),
                ItemFactory.createItemFromId(idInXML = "key-herc-level-1").copy(new = false, qty = 10u),
                ItemFactory.createItemFromId(idInXML = "grenade-christmas-2"),
                ItemFactory.createItemFromId(idInXML = "p90").copy(level = 37, quality = 3),
                ItemFactory.createItemFromId(idInXML = "sword-unique").copy(level = 49, quality = 51),
                ItemFactory.createItemFromId(itemId = AdminData.FIGHTER_WEP_ID, "bladesaw")
                    .copy(level = 58, quality = 50),
                ItemFactory.createItemFromId(itemId = AdminData.PLAYER_WEP_ID, "freedom-desert-eagle-2-replica")
                    .copy(level = 49, quality = 100),
                ItemFactory.createItemFromId(itemId = AdminData.RECON_WEP_ID, "fal-winter-2017-3")
                    .copy(level = 59, quality = 100),
                ItemFactory.createItemFromId(idInXML = "goldAK47-special").copy(level = 19, quality = 100, bind = 1u),
                ItemFactory.createItemFromId(idInXML = "helmet-wasteland-knight").copy(level = 50, quality = 100),
                ItemFactory.createItemFromId(idInXML = "christmas-canned-meat")
            )

            return Inventory(
                playerId = AdminData.PLAYER_ID,
                inventory = items,
                schematics = byteArrayOf()
            )
        }

        fun newgame(pid: String): Inventory {
            // give good weapon to do tutorial easier
            val free = setOf(
                "morningStar-2",
                "PKP",
                "an94",
                "goldAK47-special",
                "fal-winter-2017-3",
                "M249",
                "m107cq-arctic",
                "shotgun",
                "axe-halloween-2015-birthday-2017",
                "polehammer-halloween-2015-birthday-2017",
            )
            val items = listOf(
                Item(type = "pocketKnife"),
                Item(type = "lawson22"),
                Item(type = free.random())
            )
            return Inventory(
                playerId = pid,
                inventory = items,
                schematics = byteArrayOf()
            )
        }
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Inventory

        if (inventory != other.inventory) return false
        if (!schematics.contentEquals(other.schematics)) return false

        return true
    }

    override fun hashCode(): Int {
        var result = inventory.hashCode()
        result = 31 * result + schematics.contentHashCode()
        return result
    }
}

/**
 * Combine two inventory semantically (according to the game definition).
 */
fun Inventory.combineItems(other: Inventory, gameDefinitions: GameDefinitions): Inventory {
    return this.copy(inventory = this.inventory.combineItems(other.inventory, gameDefinitions))
}
