package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class WeaponFlags(val value: UInt)

object WeaponFlags_Constants {
    val NONE = WeaponFlags(0u)
    val SUPPRESSED = WeaponFlags(1u)
}
