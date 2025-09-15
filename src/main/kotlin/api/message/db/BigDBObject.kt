package dev.deadzone.api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class BigDBObject(
    val key: String = "",
    val version: String = "",
    val properties: List<ObjectProperty> = listOf(),
    val creator: UInt = 0u,
)
