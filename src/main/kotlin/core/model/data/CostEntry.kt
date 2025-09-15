package dev.deadzone.core.model.data

import kotlinx.serialization.Serializable

@Serializable
data class CostEntry(
    val key: String,
    val type: String?
)
