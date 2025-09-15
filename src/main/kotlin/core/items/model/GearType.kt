package dev.deadzone.core.items.model

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class GearType(val value: UInt)

object GearType_Constants {
    val UNKNOWN = GearType(0u)
    val PASSIVE = GearType(1u)
    val ACTIVE = GearType(2u)
    val CONSUMABLE = GearType(4u)
    val EXPLOSIVE = GearType(8u)
    val IMPROVISED = GearType(16u)
}
