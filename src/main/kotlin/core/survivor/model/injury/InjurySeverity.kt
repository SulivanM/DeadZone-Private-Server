package dev.deadzone.core.survivor.model.injury

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class InjurySeverity(val value: String)

object InjurySeverity_Constants {
    val MINOR = InjurySeverity("minor")
    val MODERATE = InjurySeverity("moderate")
    val SERIOUS = InjurySeverity("serious")
    val SEVERE = InjurySeverity("severe")
    val CRITICAL = InjurySeverity("critical")
}
