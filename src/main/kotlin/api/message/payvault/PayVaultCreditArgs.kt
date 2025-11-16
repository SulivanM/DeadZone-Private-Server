package api.message.payvault

import kotlinx.serialization.Serializable

@Serializable
data class PayVaultCreditArgs(
    val amount: UInt = 0u,
    val reason: String = "",
    val targetUserId: String = ""
)
