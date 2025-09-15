package dev.deadzone.core.model.game.data.quests

import kotlinx.serialization.Serializable

@Serializable
data class GQDataObj(
    val id: String,
    val collected: Boolean,
    val contributed: Boolean,
    val contributedLevel: Int,
    val statValues: List<UInt> = listOf()
)
