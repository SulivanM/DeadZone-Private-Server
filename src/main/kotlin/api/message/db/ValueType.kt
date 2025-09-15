package dev.deadzone.api.message.db

import kotlinx.serialization.Serializable

@Serializable
enum class ValueType {
    STRING,
    INT32,
    UINT,
    LONG,
    BOOL,
    FLOAT,
    DOUBLE,
    BYTE_ARRAY,
    DATETIME,
    ARRAY,
    OBJECT
}
