package dev.deadzone.api.message.auth

import dev.deadzone.api.message.utils.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class AuthenticateArgs(
    val gameId: String = "",
    val connectionId: String = "",
    val authenticationArguments: List<KeyValuePair> = emptyList(),
    val playerInsightSegments: List<String> = emptyList(),
    val clientAPI: String = "",
    val clientInfo: List<KeyValuePair> = emptyList(),
    val playCodes: List<String> = emptyList()
)
