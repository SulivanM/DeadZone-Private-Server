package core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
data class TargetRecord(
    val user: String,
    val time: Long
)
