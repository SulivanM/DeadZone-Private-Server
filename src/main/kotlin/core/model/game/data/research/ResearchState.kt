package dev.deadzone.core.model.game.data.research

import kotlinx.serialization.Serializable

@Serializable
data class ResearchState(
    val active: List<ResearchTask>,
    val levels: Map<String, Int>,
)
