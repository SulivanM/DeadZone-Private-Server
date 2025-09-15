package dev.deadzone.core.model.game.data

import kotlinx.serialization.Serializable

@Serializable
@JvmInline
value class Gender(val value: String)

object Gender_Constants {
    val MALE = Gender("male")
    val FEMALE = Gender("female")
    val UNKNOWN = Gender("unknown")
}
