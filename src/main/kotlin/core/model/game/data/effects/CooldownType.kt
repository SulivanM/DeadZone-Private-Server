package dev.deadzone.core.model.game.data.effects

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class CooldownType(val value: UInt)

object CooldownType_Constants {
    val Unknown = CooldownType(0u)
    val DisablePvP = CooldownType(1u)
    val Purchase = CooldownType(2u)
    val ResetLeaderAttributes = CooldownType(3u)
    val Raid = CooldownType(4u)
    val Arena = CooldownType(5u)
}
