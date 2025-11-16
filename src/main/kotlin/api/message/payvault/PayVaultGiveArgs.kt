package api.message.payvault

import kotlinx.serialization.Serializable

@Serializable
data class PayVaultGiveArgs(
    val items: List<PayVaultBuyItemInfo> = emptyList()
)
