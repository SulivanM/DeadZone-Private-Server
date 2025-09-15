package dev.deadzone.core.model.game.data.effects

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class EffectType(val value: String)

object EffectType_Constants {
    val WOOD_PRODUCTION = EffectType("WoodProduction")
    val METAL_PRODUCTION = EffectType("MetalProduction")
    val CLOTH_PRODUCTION = EffectType("ClothProduction")
    val AMMO_PRODUCTION = EffectType("AmmoProduction")
    val FOOD_PRODUCTION = EffectType("FoodProduction")
    val WATER_PRODUCTION = EffectType("WaterProduction")
}
