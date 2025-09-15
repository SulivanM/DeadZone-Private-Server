package dev.deadzone.core.model.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class KeyFlags(val value: UInt)

object KeyFlags_Constants {
    val NONE = KeyFlags(0u)
    val CONTROL = KeyFlags(1u)
    val SHIFT = KeyFlags(2u)
}
