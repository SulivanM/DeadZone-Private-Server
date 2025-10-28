package server.handler.save.item.response

import kotlinx.serialization.Serializable

@Serializable
data class ItemBatchRecycleSpeedUpResponse(
    val error: String = "",
    val success: Boolean = true,
    val cost: Int = 0
)
