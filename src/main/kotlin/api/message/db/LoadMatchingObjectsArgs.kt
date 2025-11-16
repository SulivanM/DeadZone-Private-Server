package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class LoadMatchingObjectsArgs(
    val table: String = "",
    val index: String = "",
    val indexValue: List<ValueObject> = emptyList(),
    val limit: Int = 0
)
