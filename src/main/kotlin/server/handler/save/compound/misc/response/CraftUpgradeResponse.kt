package server.handler.save.compound.misc.response

import core.items.model.Item
import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class CraftUpgradeResponse(
    val success: Boolean = true,
    val item: String? = null,  // Item ID
    val level: Int? = null,  // New level after upgrade
    val change: Map<String, Int>? = null,  // Inventory quantity changes
    val winmaxlevel: Boolean? = null,  // True if item reached max level
    val error: String? = null  // Error message if failed
): BaseResponse()
