package core.model.game.data.skills

import kotlinx.serialization.Serializable
import core.model.game.data.skills.SkillState

@Serializable
data class SkillCollection(
    val map: Map<String, SkillState>? = mapOf()
)
