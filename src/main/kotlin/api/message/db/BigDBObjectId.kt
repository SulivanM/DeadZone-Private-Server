package dev.deadzone.api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class BigDBObjectId(
    val table: String = "",
    val keys: List<String> = listOf()
)
