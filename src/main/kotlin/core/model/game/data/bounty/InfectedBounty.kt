package dev.deadzone.core.model.game.data.bounty

import kotlinx.serialization.Serializable
import dev.deadzone.core.model.game.data.bounty.InfectedBountyTask

@Serializable
data class InfectedBounty(
    val id: String,
    val completed: Boolean,
    val abandoned: Boolean,
    val viewed: Boolean,
    val rewardItemId: String,
    val issueTime: Long,
    val tasks: List<InfectedBountyTask> = listOf()
)
