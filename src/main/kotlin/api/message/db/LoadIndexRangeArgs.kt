package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class LoadIndexRangeArgs(
    val table: String,
    val index: String,
    val startIndexValue: List<ValueObject> = emptyList(),
    val stopIndexValue: List<ValueObject> = emptyList(),
    val limit: Int = 0
)
