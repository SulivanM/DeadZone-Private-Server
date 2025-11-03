package server.handler.save.crate.response

import core.items.ItemFactory
import core.items.model.Item
import kotlinx.serialization.Serializable

@Serializable
data class CrateUnlockResponse(
    val success: Boolean = true,
    val item: Item = ItemFactory.getRandomItem(),
    val effect: String? = null,
    val cooldown: String? = null,
    val keyId: String? = null,
    val keyQty: Int? = null,
    val crateId: String? = null,
)

val gachaPoolExample = listOf(
    ItemFactory.createItemFromId(idInXML = "exo-rig-heavyBrawler-replica"),
    ItemFactory.createItemFromId(idInXML = "helmet-exo-brawler-replica"),
    ItemFactory.createItemFromId(idInXML = "helmet-exo-targeting-replica"),
    ItemFactory.createItemFromId(idInXML = "mask-herc-exo-replica"),
    ItemFactory.createItemFromId(idInXML = "exo-undershirt-1-replica"),
    ItemFactory.createItemFromId(idInXML = "exo-underpants-1-replica"),
    ItemFactory.createItemFromId(idInXML = "pistol-halloween-reborn"),
    ItemFactory.createItemFromId(idInXML = "pistol-halloween-2-reborn"),
    ItemFactory.createItemFromId(idInXML = "rifle-halloween-reborn"),
    ItemFactory.createItemFromId(idInXML = "rifle-halloween-2-reborn"),
    ItemFactory.createItemFromId(idInXML = "sword-laser-purple-reborn"),
    ItemFactory.createItemFromId(idInXML = "trident-halloween-reborn"),
    ItemFactory.createItemFromId(idInXML = "trident-halloween-2-reborn"),
    ItemFactory.createItemFromId(idInXML = "crossbow-halloween-2015-reborn"),
    ItemFactory.createItemFromId(idInXML = "crossbow-halloween-2015-2-reborn"),
    ItemFactory.createItemFromId(idInXML = "halloween-exo-zombie"),
    ItemFactory.createItemFromId(idInXML = "bladesaw"),
    ItemFactory.createItemFromId(idInXML = "warclub")
)
