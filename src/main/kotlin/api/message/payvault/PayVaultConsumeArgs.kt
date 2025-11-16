package api.message.payvault

import kotlinx.serialization.Serializable

@Serializable
data class PayVaultConsumeArgs(
    val ids: List<String> = emptyList(),
    val targetUserId: String = ""
)
