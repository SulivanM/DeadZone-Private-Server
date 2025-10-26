package server.handler.save.compound.building.response

import dev.deadzone.core.model.game.data.TimerData
import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable

@Serializable
data class BuildingUpgradeResponse(
    val success: Boolean = true,
    val items: Map<String, Int>? = emptyMap(),
    val timer: TimerData?,
    val xp: Int = 0,
    val level: Int? = null,
    val levelPts: Int? = null,
): BaseResponse()
