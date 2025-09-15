package dev.deadzone.core.model.game.data.effects

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class EffectSaveFlags(val value: UInt)

object EffectSaveFlags_Constants {
    val NONE = EffectSaveFlags(0u)
    val CONSUMABLE = EffectSaveFlags(1u)
    val PERMANENT = EffectSaveFlags(2u)
    val LINKED_ITEM = EffectSaveFlags(4u)
}
