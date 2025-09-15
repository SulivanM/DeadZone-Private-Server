package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class WeaponType(val value: UInt)

object WeaponType_Constants {
    val NONE = WeaponType(0u)
    val AUTO = WeaponType(1u)
    val SEMI_AUTO = WeaponType(2u)
    val ONE_HANDED = WeaponType(4u)
    val TWO_HANDED = WeaponType(8u)
    val IMPROVISED = WeaponType(16u)
    val EXPLOSIVE = WeaponType(32u)
    val BLADE = WeaponType(64u)
    val BLUNT = WeaponType(128u)
    val AXE = WeaponType(256u)
    val SPECIAL = WeaponType(512u)
}
