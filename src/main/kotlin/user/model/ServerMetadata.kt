package user.model

import kotlinx.serialization.Serializable

@Serializable
data class ServerMetadata(
    val notes: String? = null,
    val flags: Map<String, Boolean> = emptyMap(),
    val extra: Map<String, String> = emptyMap(),
)
