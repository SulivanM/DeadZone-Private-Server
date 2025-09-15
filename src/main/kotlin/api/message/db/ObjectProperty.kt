package dev.deadzone.api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class ObjectProperty(
    val name: String = "",
    val value: ValueObject = ValueObject()
)
