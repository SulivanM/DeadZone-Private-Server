package core.items.model

import kotlinx.serialization.Serializable

@Serializable
data class SchematicItem(
    val type: String,
    val schem: String,
    val id: String = "",
    val new: Boolean = false,
    val storeId: String? = null
)
