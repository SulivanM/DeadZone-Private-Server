package dev.deadzone.core.survivor.model.injury

import kotlinx.serialization.Serializable

@Serializable
data class InjuryList(
    val list: List<Injury> = listOf(),  // casted to array in code
)
