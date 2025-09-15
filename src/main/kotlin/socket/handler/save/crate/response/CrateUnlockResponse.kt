package dev.deadzone.socket.handler.save.crate.response

import dev.deadzone.core.items.ItemFactory
import dev.deadzone.core.items.model.Item
import kotlinx.serialization.Serializable

@Serializable
data class CrateUnlockResponse(
    val success: Boolean = true,
    val item: Item = ItemFactory.getRandomItem(),
    val effect: String? = null,   // base64 encoded, parsed to [Effect]
    val cooldown: String? = null, // similar as above
    val keyId: String? = null, // to remove the key used to open the crate
    val keyQty: Int? = null, // to remove the key used to open the crate
    val crateId: String? = null, // to remove the opened crate
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
