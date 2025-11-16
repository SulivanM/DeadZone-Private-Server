@file:Suppress("UNCHECKED_CAST")

package common

import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.KSerializer
import kotlinx.serialization.SerializationStrategy
import kotlinx.serialization.builtins.MapSerializer
import kotlinx.serialization.builtins.serializer
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder
import kotlinx.serialization.json.*

/**
 * Preset JSON serialization and deserialization.
 */
object JSON {
    lateinit var json: Json

    fun initialize(json: Json) {
        this.json = json
    }

    inline fun <reified T> encode(value: T): String {
        return json.encodeToString<T>(value)
    }

    inline fun <reified T> encode(serializer: SerializationStrategy<T>, value: T): String {
        return json.encodeToString(serializer, value)
    }

    inline fun <reified T> decode(value: String): T {
        return json.decodeFromString<T>(value)
    }

    inline fun <reified T> decode(deserializer: DeserializationStrategy<T>, value: String): T {
        return json.decodeFromString(deserializer, value)
    }
}

/**
 * Serializer for Map<String, Any>
 */
object AnyMapSerializer : KSerializer<Map<String, Any>> {
    override val descriptor: SerialDescriptor =
        MapSerializer(String.serializer(), JsonElement.serializer()).descriptor

    @Suppress("UNCHECKED_CAST")
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

/**
 * Parse JSON string to Map
 */
fun parseJsonToMap(json: String): Map<String, Any?> {
    return try {
        val parsed = JSON.decode<JsonObject>(json)
        parsed.mapValues { (_, v) -> parseJsonElement(v) }
    } catch (_: Exception) {
        emptyMap()
    }
}

/**
 * Parse JsonElement to Any
 */
fun parseJsonElement(el: JsonElement): Any = when (el) {
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

/**
 * Convert Map to JsonElement
 */
fun Map<String, *>?.toJsonElement(): JsonObject = buildJsonObject {
    this@toJsonElement?.forEach { (key, value) ->
        put(key, value.toJsonValue())
    }
}

/**
 * Convert Any to JsonValue
 */
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
