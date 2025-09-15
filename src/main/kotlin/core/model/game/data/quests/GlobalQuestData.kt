package dev.deadzone.core.model.game.data.quests

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.quests.GQDataObj

@Serializable
data class GlobalQuestData(
    val raw: ByteArray,
    val map: Map<String, GQDataObj> = mapOf()
)
