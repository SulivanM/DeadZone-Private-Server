package api.message.db

import kotlinx.serialization.Serializable

/**
 * Mirrors PlayerIO BigDB LoadIndexRange args:
 * - table: BigDB table name
 * - index: index name within the table
 * - startIndexValue: inclusive start of index (composite allowed)
 * - stopIndexValue: inclusive stop of index (composite allowed)
 * - limit: maximum number of objects to return
 */
@Serializable
data class LoadIndexRangeArgs(
    val table: String,
    val index: String,
    val startIndexValue: List<ValueObject> = emptyList(),
    val stopIndexValue: List<ValueObject> = emptyList(),
    val limit: Int = 0
)