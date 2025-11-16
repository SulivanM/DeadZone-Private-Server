package api.message.payvault

import kotlinx.serialization.Serializable

@Serializable
data class PayVaultRefreshOutput(
    val version: String = "",
    val coins: Long = 0,
    val items: List<PayVaultItem> = emptyList()
)

@Serializable
data class PayVaultItem(
    val id: String = "",
    val itemKey: String = "",
    val purchaseDate: Long = 0
)
