package dev.deadzone.core.items.model

import kotlinx.serialization.Serializable

@Serializable
data class EffectItem(
    val effect: ByteArray,  // see effect.as for bytearray specification
)
