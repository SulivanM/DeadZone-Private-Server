package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.WeaponClass
import dev.deadzone.core.model.game.data.WeaponType

@Serializable
data class SurvivorClassWeapons(
    val classes: List<WeaponClass> = listOf(),
    val types: List<WeaponType> = listOf()
)
