package dev.deadzone.core.auth.model

import kotlinx.serialization.Serializable

/**
 * Extra data for server. This is unused, but prepared just in case it is needed.
 *
 * May include cheat tracking or activity analysis here.
 */
@Serializable
data class ServerMetadata(
    val notes: String? = null,
    val flags: Map<String, Boolean> = emptyMap(),
    val extra: Map<String, String> = emptyMap(),
)
