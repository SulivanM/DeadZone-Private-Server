package api.message.payvault

import kotlinx.serialization.Serializable

@Serializable
data class PayVaultRefreshArgs(
    val lastVersion: String = "",
    val targetUserId: String = ""
)
