package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class BigDBChangeset(
    val table: String = "",
    val key: String = "",
    val onlyIfVersion: String = "",
    val changes: List<ObjectProperty> = listOf(),
    val fullOverwrite: Boolean = false,
)
