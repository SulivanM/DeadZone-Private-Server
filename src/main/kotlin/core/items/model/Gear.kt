package dev.deadzone.core.items.model

import dev.deadzone.core.model.game.data.AttireData
import kotlinx.serialization.Serializable

@Serializable
data class Gear(
    val _attireXMLInvalid: Boolean = false,
    val animType: String = "",
    val attire: List<AttireData> = listOf(),
    val attireXMLList: List<String> = listOf(),  // List<XMLList> actually
    val gearType: UInt = 1u,
    val gearClass: String = "",
    val requiredSurvivorClass: String?,
    val carryLimit: Int = 0,
    val survivorClasses: List<String> = listOf(),
    val weaponClasses: List<String> = listOf(),
    val weaponTypes: UInt = 0u,
    val ammoTypes: UInt = 0u,
    val activeAttributes: ItemAttributes
)
