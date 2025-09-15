package dev.deadzone.core.model.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class PlayerUpgrades(val value: Int)

object PlayerUpgrades_Constants {
    val DeathMobileUpgrade = PlayerUpgrades(0)
    val TradeSlotUpgrade = PlayerUpgrades(1)
    val InventoryUpgrade1_UNUSED = PlayerUpgrades(2)
}
