package dev.deadzone.api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class ArrayProperty(
    val index: Int = 0,
    val value: ValueObject = ValueObject()
)
