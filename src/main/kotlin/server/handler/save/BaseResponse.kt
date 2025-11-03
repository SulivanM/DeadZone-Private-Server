package server.handler.save

import core.model.game.data.skills.SkillState

open class BaseResponse {
    val coins: Int? = null
    val skills: List<SkillState>? = null
}
