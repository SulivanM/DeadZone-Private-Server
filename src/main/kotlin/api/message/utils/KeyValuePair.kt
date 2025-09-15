package dev.deadzone.api.message.utils

import kotlinx.serialization.Serializable

@Serializable
data class KeyValuePair(
    val key: String = "",
    val value: String = "",
) {
    companion object {
        fun dummy(): KeyValuePair {
            return KeyValuePair(
                key = "examplekey",
                value = "examplevalue",
            )
        }
    }
}
