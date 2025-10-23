package server.handler.save

import core.model.game.data.skills.SkillState

/**
 * Most save message expects coins and skills update from server, which can be left null
 *
 * @property coins also known as CASH or FUEL in the game
 * @property skills not sure what is this
 */
open class BaseResponse {
    val coins: Int? = null
    val skills: List<SkillState>? = null
}