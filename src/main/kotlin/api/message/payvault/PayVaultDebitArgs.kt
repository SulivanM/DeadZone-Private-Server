package api.message.payvault

import kotlinx.serialization.Serializable

@Serializable
data class PayVaultDebitArgs(
    val amount: UInt = 0u,
    val reason: String = "",
    val targetUserId: String = ""
)
