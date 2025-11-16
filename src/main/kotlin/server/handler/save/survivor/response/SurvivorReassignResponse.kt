package server.handler.save.survivor.response

import server.handler.save.BaseResponse
import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.TimerData

@Serializable
data class SurvivorReassignResponse(
    val success: Boolean = true,
    val error: String? = null,
    val id: String? = null,
    val classId: String? = null,
    val level: Int? = null,
    val xp: Int? = null,
    val timer: TimerData? = null
): BaseResponse()
