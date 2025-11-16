package data.collection

import kotlinx.serialization.Serializable

@Serializable
data class PayVaultData(
    val playerId: String,
    val version: String = System.currentTimeMillis().toString(),
    val coins: Long = 0,
    val items: List<PayVaultItemData> = emptyList()
) {
    companion object {
        fun empty(playerId: String) = PayVaultData(
            playerId = playerId,
            version = System.currentTimeMillis().toString(),
            coins = 0,
            items = emptyList()
        )
    }
}

@Serializable
data class PayVaultItemData(
    val id: String,
    val itemKey: String,
    val purchaseDate: Long
)
