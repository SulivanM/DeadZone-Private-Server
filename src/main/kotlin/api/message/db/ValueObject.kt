package dev.deadzone.api.message.db

import kotlinx.serialization.Serializable

@Serializable
data class ValueObject(
    val valueType: ValueType = ValueType.STRING,
    val string: String = "",
    val int32: Int = 0,
    val uInt: UInt = 0u,
    val long: Long = 0L,
    val bool: Boolean = false,
    val float: Float = 0f,
    val double: Double = 0.0,
    val byteArray: ByteArray = byteArrayOf(),
    val dateTime: Long = 0L,
    val arrayProperties: List<ArrayProperty> = listOf(),
    val objectProperties: List<ObjectProperty> = listOf()
)
