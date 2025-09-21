package core.model.game.data

import kotlinx.serialization.Serializable
import core.model.game.data.MissionData

@Serializable
data class MissionCollection(
    val list: List<MissionData> = listOf()
)
