package api.message.payvault

import api.message.KeyValuePair
import kotlinx.serialization.Serializable

@Serializable
data class PayVaultPaymentInfoArgs(
    val provider: String = "",
    val purchaseArguments: List<KeyValuePair> = emptyList(),
    val items: List<PayVaultBuyItemInfo> = emptyList()
)
