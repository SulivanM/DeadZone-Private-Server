package dev.deadzone.core.model.game.data.quests

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class DynamicQuestType(val value: Int)

object DynamicQuestType_Constants {
    val SURVIVOR_REQUEST = DynamicQuestType(0)
}
