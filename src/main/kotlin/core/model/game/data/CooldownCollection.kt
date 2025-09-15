package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
data class CooldownCollection(
    val byteArray: Map<String, ByteArray> = mapOf(),  // will be parsed to Cooldown
)
