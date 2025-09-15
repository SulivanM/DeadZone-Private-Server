package dev.deadzone.core.model.game.data.bounty

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.bounty.InfectedBountyTaskCondition

@Serializable
data class InfectedBountyTask(
    val suburb: String,
    val conditions: List<InfectedBountyTaskCondition> = listOf()
)
