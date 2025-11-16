package api.message.auth

import api.message.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class AuthenticateStartDialog(
    val name: String = "",
    val arguments: List<KeyValuePair> = emptyList()
)