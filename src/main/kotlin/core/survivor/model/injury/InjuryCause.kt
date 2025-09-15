package dev.deadzone.core.survivor.model.injury

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class InjuryCause(val value: String)

object InjuryCause_Constants {
    val UNKNOWN = InjuryCause("unknown")
    val BLUNT = InjuryCause("blunt")
    val SHARP = InjuryCause("sharp")
    val HEAT = InjuryCause("heat")
    val BULLET = InjuryCause("bullet")
    val ILLNESS = InjuryCause("illness")
}
