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
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.jsonObject

object AnyMapSerializer : KSerializer<Map<String, Any>> {
    override val descriptor: SerialDescriptor =
        MapSerializer(String.serializer(), JsonElement.serializer()).descriptor

    override fun serialize(encoder: Encoder, value: Map<String, Any>) {
        val jsonEncoder = encoder as? JsonEncoder
            ?: error("This serializer only works with JSON")
        val converted = value.mapValues { (_, v) ->
            when (v) {
                is JsonElement -> v
                is String -> JsonPrimitive(v)
                is Number -> JsonPrimitive(v)
                is Boolean -> JsonPrimitive(v)
                is Map<*, *> -> JsonObject((v as Map<String, Any>).mapValues { JsonPrimitive(it.value.toString()) })
                is List<*> -> JsonArray(v.map { JsonPrimitive(it.toString()) })
                else -> JsonPrimitive(v.toString())
            }
        }
        jsonEncoder.encodeJsonElement(JsonObject(converted))
    }

    override fun deserialize(decoder: Decoder): Map<String, Any> {
        val jsonDecoder = decoder as? JsonDecoder
            ?: error("This serializer only works with JSON")
        val obj = jsonDecoder.decodeJsonElement().jsonObject
        return obj.mapValues { it.value }
    }
}
