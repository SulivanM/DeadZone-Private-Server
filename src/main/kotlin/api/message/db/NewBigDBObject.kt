package api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class NewBigDBObject(
    val table: String = "",
    val key: String = "",
    val properties: List<ObjectProperty> = listOf(),
)
