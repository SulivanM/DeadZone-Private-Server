package api.message.payvault

import api.message.db.ObjectProperty
import kotlinx.serialization.Serializable

@Serializable
data class PayVaultBuyItemInfo(
    val itemKey: String = "",
    val payload: List<ObjectProperty> = emptyList()
)
