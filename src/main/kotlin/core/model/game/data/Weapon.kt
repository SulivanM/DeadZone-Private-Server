package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.core.survivor.model.injury.InjuryCause

@Serializable
data class Weapon(
    val attachments: List<String>,
    val burstFire: Boolean,
    val injuryCause: InjuryCause,
    val weaponClass: WeaponClass,
    val animType: String,
    val reloadAnim: String,
    val swingAnims: List<String>,
    val playSwingExertionSound: Boolean = true,
    val flags: UInt = 0u,
    val weaponType: UInt = 0u,
    val ammoType: UInt = 0u,
    val survivorClasses: List<String> = listOf()
)
