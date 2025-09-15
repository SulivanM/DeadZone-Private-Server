package dev.deadzone.utils

import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.boolean
import kotlinx.serialization.json.booleanOrNull
import kotlinx.serialization.json.buildJsonArray
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.double
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.int
import kotlinx.serialization.json.intOrNull
import kotlinx.serialization.json.long
import kotlinx.serialization.json.longOrNull
import kotlin.collections.map
import kotlin.collections.mapValues

fun parseJsonToMap(json: String): Map<String, Any?> {
    return try {
        val parsed = Json.decodeFromString<JsonObject>(json)
        parsed.mapValues { (_, v) -> parseJsonElement(v) }
    } catch (_: Exception) {
        emptyMap()
    }
}

fun parseJsonElement(el: JsonElement): Any? = when (el) {
    is JsonPrimitive -> {
        when {
            el.isString -> el.content
            el.booleanOrNull != null -> el.boolean
            el.intOrNull != null -> el.int
            el.longOrNull != null -> el.long
            el.doubleOrNull != null -> el.double
            else -> el.content
        }
    }

    is JsonObject -> el.mapValues { parseJsonElement(it.value) }
    is JsonArray -> el.map { parseJsonElement(it) }
}

fun Map<String, *>?.toJsonElement(): JsonObject = buildJsonObject {
    this@toJsonElement?.forEach { (key, value) ->
        put(key, value.toJsonValue())
    }
}

fun Any?.toJsonValue(): JsonElement = when (this) {
    null -> JsonNull
    is String -> JsonPrimitive(this)
    is Number -> JsonPrimitive(this)
    is Boolean -> JsonPrimitive(this)
    is Map<*, *> -> {
        // Keys must be strings for JSON
        (this as? Map<String, *>)?.toJsonElement()
            ?: error("Map keys must be strings: $this")
    }
    is Iterable<*> -> buildJsonArray { this@toJsonValue.forEach { add(it.toJsonValue()) } }
    else -> JsonPrimitive(this.toString()) // fallback — stores as string
}
