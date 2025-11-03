package core.model.game.data.quests

import kotlinx.serialization.Serializable

@Serializable
data class Quest(
    
    val id: String,
    val index: Int,
    val type: String,

    val started: Boolean = false,
    val complete: Boolean = false,
    val collected: Boolean = false,
    val failed: Boolean = false,
    val new: Boolean = false,
    val visible: Boolean = true,

    val conditionProgress: List<Int> = listOf(),

    val isAchievement: Boolean = false,
    val important: Boolean = false,
    val timeBased: Boolean = false,
    val level: Int = 0,
    val secretLevel: UInt = 0u,

    val startImageURI: String? = null,
    val completeImageURI: String? = null,
    val xml: String? = null,  

    val startTime: Long? = null,
    val endTime: Long? = null,

    val children: List<Quest> = listOf()
)
