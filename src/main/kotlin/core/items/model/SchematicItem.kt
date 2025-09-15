package dev.deadzone.core.items.model

import kotlinx.serialization.Serializable

@Serializable
data class SchematicItem(
    val type: String,
    val schem: String,
    val id: String = "",  // actually default a GUID.create()
    val new: Boolean = false,
    val storeId: String? = null
)
