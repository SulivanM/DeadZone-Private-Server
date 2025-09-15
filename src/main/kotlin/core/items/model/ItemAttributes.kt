package dev.deadzone.core.items.model

import kotlinx.serialization.Serializable

@Serializable
data class ItemAttributes(
    val baseValues: Map<String, Map<String, Double>> = mapOf(),
    val modValues: Map<String, Map<String, Double>> = mapOf(),
    val attCaps: Map<String, Map<String, Double>> = mapOf()
)
