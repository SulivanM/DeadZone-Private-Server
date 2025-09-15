package dev.deadzone.core.model.game.data.bounty

import kotlinx.serialization.Serializable

@Serializable
data class InfectedBountyTaskCondition(
    val zombieType: String,
    val killsRequired: Int,
    val kills: Int
)
