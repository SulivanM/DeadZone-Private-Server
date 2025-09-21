package core.model.game.data

import kotlinx.serialization.Serializable
import core.model.game.data.WeaponClass
import core.model.game.data.WeaponType

@Serializable
data class SurvivorClassWeapons(
    val classes: List<WeaponClass> = listOf(),
    val types: List<WeaponType> = listOf()
)
