package dev.deadzone.api.message.auth

import dev.deadzone.api.message.utils.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class AuthenticateStartDialog(
    val name: String = "",
    val arguments: List<KeyValuePair> = emptyList()
)
