package api.message.payvault

import kotlinx.serialization.Serializable

@Serializable
data class PayVaultBuyArgs(
    val items: List<PayVaultBuyItemInfo> = emptyList(),
    val storeItems: Boolean = true
)
