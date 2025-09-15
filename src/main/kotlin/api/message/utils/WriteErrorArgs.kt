package dev.deadzone.api.message.utils

import kotlinx.serialization.Serializable

@Serializable
data class WriteErrorArgs(
    val source: String = "",
    val error: String = "",
    val details: String = "",
    val stacktrace: String = "",
    val extraData: List<KeyValuePair> = listOf(),
)
