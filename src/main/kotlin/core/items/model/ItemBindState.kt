package dev.deadzone.core.items.model

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class ItemBindState(val value: UInt)

object ItemBindState_Constants {
    val NotBindable = ItemBindState(0u)
    val OnEquip = ItemBindState(1u)
    val Bound = ItemBindState(2u)
}
