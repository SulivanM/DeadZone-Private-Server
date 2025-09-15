package dev.deadzone.core.model.game.data.skills

import kotlinx.serialization.Serializable

@Serializable
data class SkillState(
    val xp: Int,
    val level: Int
)
