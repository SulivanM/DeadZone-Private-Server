package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class WeaponClass(val value: String)

object WeaponClass_Constants {
    val ASSAULT_RIFLE = WeaponClass("assault_rifle")
    val BOW = WeaponClass("bow")
    val LAUNCHER = WeaponClass("launcher")
    val LONG_RIFLE = WeaponClass("long_rifle")
    val MELEE = WeaponClass("melee")
    val PISTOL = WeaponClass("pistol")
    val SHOTGUN = WeaponClass("shotgun")
    val SMG = WeaponClass("smg")
    val LMG = WeaponClass("lmg")
    val THROWN = WeaponClass("thrown")
    val HEAVY = WeaponClass("heavy")
}
