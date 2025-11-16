package core.model.game.data.alliance

import kotlinx.serialization.Serializable

@Serializable
data class AllianceWinnings(
    val uncollected: Int = 0,  // Fuel non collecté
    val lifetime: Int = 0       // Total de fuel gagné depuis le début
)
