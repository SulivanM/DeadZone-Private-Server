package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.effects.Effect

@Serializable
data class EffectCollection(
    val list: List<ByteArray> = listOf()
) {
    fun dummy(): EffectCollection {
        return EffectCollection(
            list = listOf(byteArrayOf())
        )
    }
}
