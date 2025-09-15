package dev.deadzone.core.model.game.data.quests

import kotlinx.serialization.Serializable

@Serializable
data class Quest(
    val id: String,
    val started: Boolean,
    val complete: Boolean,
    val conditionProgress: List<Int> = listOf(),
    val collected: Boolean,
    val index: Int,
    val important: Boolean,
    val startImageURI: String?,
    val completeImageURI: String?,
    val isAchievement: Boolean,
    val level: Int,
    val secretLevel: UInt = 0u,
    val type: String,
    val xml: String?,  // uses XML type actually
    val new: Boolean,
    val children: List<Quest> = listOf(),
    val startTime: Long?,
    val endTime: Long?,
    val failed: Boolean,
    val timeBased: Boolean,
    val visible: Boolean = true
)
