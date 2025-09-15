package dev.deadzone.api.utils

import dev.deadzone.api.message.db.ArrayProperty
import dev.deadzone.api.message.db.BigDBObject
import dev.deadzone.api.message.db.ObjectProperty
import dev.deadzone.api.message.db.ValueObject
import dev.deadzone.api.message.db.ValueType
import kotlin.reflect.KProperty1
import kotlin.reflect.KVisibility

object BigDBConverter {
    inline fun <reified T : Any> toBigDBObject(key: String = "", obj: T, creator: UInt = 0u): BigDBObject {
        val props = toObjectProperties(obj)
        return BigDBObject(
            key = key,
            version = "1",
            properties = props,
            creator = creator
        )
    }

    fun toValueObject(value: Any?, isDate: Boolean? = null): ValueObject {
        return when (value) {
            null -> ValueObject(valueType = ValueType.STRING, string = "")
            is String -> ValueObject(valueType = ValueType.STRING, string = value)
            is Int -> ValueObject(valueType = ValueType.INT32, int32 = value)
            is UInt -> ValueObject(valueType = ValueType.UINT, uInt = value)
            is Long -> {
                if (isDate == true) {
                    ValueObject(valueType = ValueType.DATETIME, dateTime = value)
                } else {
                    ValueObject(valueType = ValueType.LONG, long = value)
                }
            }
            is Boolean -> ValueObject(valueType = ValueType.BOOL, bool = value)
            is Float -> ValueObject(valueType = ValueType.FLOAT, float = value)
            is Double -> ValueObject(valueType = ValueType.DOUBLE, double = value)
            is ByteArray -> ValueObject(valueType = ValueType.BYTE_ARRAY, byteArray = value)
            is List<*> -> ValueObject(
                valueType = ValueType.ARRAY,
                arrayProperties = value.mapIndexed { idx, v ->
                    ArrayProperty(index = idx, value = toValueObject(v))
                }
            )

            is Map<*, *> -> {
                val props = value.entries.mapNotNull { (k, v) ->
                    k?.toString()?.let { ObjectProperty(it, toValueObject(v)) }
                }
                ValueObject(valueType = ValueType.OBJECT, objectProperties = props)
            }

            is Enum<*> -> ValueObject(valueType = ValueType.STRING, string = value.name)
            else -> {
                val props = toObjectProperties(value)
                ValueObject(valueType = ValueType.OBJECT, objectProperties = props)
            }
        }
    }

    fun toObjectProperties(obj: Any): List<ObjectProperty> {
        val reserved = setOf("key", "creator", "version")
        val knownDateKeys = setOf("nextDZBountyIssue", "lastLogout", "lastLogin", "prevLogin")

        return obj::class.members
            .filterIsInstance<KProperty1<Any, *>>()
            .filter { it.visibility == KVisibility.PUBLIC }
            .mapNotNull { prop ->
                val name = prop.name
                if (name in reserved) return@mapNotNull null
                val value = try {
                    prop.get(obj)
                } catch (e: Exception) {
                    null
                }

                if (value == null) return@mapNotNull null

                if (name in knownDateKeys) {
                    ObjectProperty(name, toValueObject(value, true))
                } else {
                    ObjectProperty(name, toValueObject(value))
                }
            }
    }
}