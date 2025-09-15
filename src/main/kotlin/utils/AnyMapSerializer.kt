package dev.deadzone.utils

import kotlinx.serialization.KSerializer
import kotlinx.serialization.builtins.MapSerializer
import kotlinx.serialization.builtins.serializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonDecoder
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonEncoder
import kotlinx.serialization.json.JsonNull
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.jsonObject

object AnyMapSerializer : KSerializer<Map<String, Any>> {
    override val descriptor: SerialDescriptor =
        MapSerializer(String.serializer(), JsonElement.serializer()).descriptor

    override fun serialize(encoder: Encoder, value: Map<String, Any>) {
        val jsonEncoder = encoder as? JsonEncoder
            ?: error("This serializer only works with JSON")
        val jsonObject = JsonObject(
            value.entries.associate { (k, v) -> k to toJsonElement(v) }
        )
        jsonEncoder.encodeJsonElement(jsonObject)
    }

    private fun toJsonElement(v: Any?): JsonElement {
        return when (v) {
            null -> JsonNull
            is JsonElement -> v
            is String -> JsonPrimitive(v)
            is Number -> JsonPrimitive(v)
            is Boolean -> JsonPrimitive(v)
            is Map<*, *> -> {
                val mapped = v.entries
                    .mapNotNull { (key, value) ->
                        (key as? String)?.let { it to toJsonElement(value) }
                    }
                    .toMap()
                JsonObject(mapped)
            }
            is Iterable<*> -> JsonArray(v.map { toJsonElement(it) })
            is Array<*> -> JsonArray(v.map { toJsonElement(it) })
            else -> JsonPrimitive(v.toString())
        }
    }

    override fun deserialize(decoder: Decoder): Map<String, Any> {
        val jsonDecoder = decoder as? JsonDecoder
            ?: error("This serializer only works with JSON")
        val obj = jsonDecoder.decodeJsonElement().jsonObject
        return obj.mapValues { it.value }
    }
}