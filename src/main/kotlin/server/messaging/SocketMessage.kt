package server.messaging

import common.parseJsonToMap

/**
 * A higher-level representation of game message sent to the socket server.
 *
 * Message is always a flat list of even length (if odd then the first is the type).
 * Two of each element is paired as key-value pair.
 *
 * @constructor Raw deserialized data received from socket connection
 *
 */
class SocketMessage(private val raw: List<Any>) {
    val type: String? = if (raw.size % 2 == 1 && raw.size != 1) raw.firstOrNull() as? String else null

    private val map: Map<String, Any?> = buildMap {
        val start = if (type != null) 1 else 0
        val end = raw.size
        for (i in start until end step 2) {
            val key = raw.getOrNull(i) as? String ?: continue
            val value = raw.getOrNull(i + 1)
            put(key, value)
        }
    }

    fun isEmpty(): Boolean {
        return map.keys.isEmpty()
    }

    /**
     * Type of socket message in String.
     *
     * This will check [type] (which is non-null string if length of message is odd).
     * The fallback will be the first key of the message map.
     * If message type is not able to be determined after these two, this will return `[Undetermined]`
     */
    fun msgTypeToString(): String {
        if (map.keys.firstOrNull() == "s") {
            return "save/${getSaveSubType()}"
        }
        return type ?: (map.keys.firstOrNull() ?: "[Undetermined]")
    }

    @Suppress("UNCHECKED_CAST")
    fun getSaveSubType(): String {
        return (this.getMap("s")?.get("data") as? Map<String, Any?>)?.get("_type") as String? ?: ""
    }

    /**
     * Get a value (`any` type) from particular key.
     * Use [getString], [getInt], etc for typed result
     *
     * @param key
     * @return the value from the corresponding key in the message
     */
    fun get(key: String): Any? = map[key]

    fun contains(key: String): Boolean {
        return map.containsKey(key)
    }

    fun getString(key: String): String? = map[key] as? String
    fun getInt(key: String): Int? = (map[key] as? Number)?.toInt()
    fun getLong(key: String): Long? = (map[key] as? Number)?.toLong()
    fun getBoolean(key: String): Boolean? = map[key] as? Boolean
    fun getDouble(key: String): Double? = (map[key] as? Number)?.toDouble()

    // Index-based access (for messages with positional parameters)
    fun getString(index: Int): String? = raw.getOrNull(if (type != null) index + 1 else index) as? String
    fun getInt(index: Int): Int? = (raw.getOrNull(if (type != null) index + 1 else index) as? Number)?.toInt()
    fun getLong(index: Int): Long? = (raw.getOrNull(if (type != null) index + 1 else index) as? Number)?.toLong()
    fun getBoolean(index: Int): Boolean? = raw.getOrNull(if (type != null) index + 1 else index) as? Boolean
    fun getDouble(index: Int): Double? = (raw.getOrNull(if (type != null) index + 1 else index) as? Number)?.toDouble()

    @Suppress("UNCHECKED_CAST")
    fun getList(key: String): List<Any?>? = map[key] as? List<Any?>

    @Suppress("UNCHECKED_CAST")
    fun getMap(key: String): Map<String, Any?>? {
        val rawValue = map[key] ?: return null
        return when (rawValue) {
            is Map<*, *> -> rawValue as? Map<String, Any?>
            is String -> {
                try {
                    parseJsonToMap(rawValue)
                } catch (_: Exception) {
                    null
                }
            }

            else -> null
        }
    }

    // Get all map keys (useful for FLAG_CHANGED where flag name is dynamic)
    fun getKeys(): Set<String> = map.keys

    // Get raw list for debugging
    fun getRaw(): List<Any> = raw

    override fun toString(): String = if (type != null)
        "Message(type=$type, map=$map)"
    else
        "Message(map=$map)"

    companion object {
        fun fromRaw(raw: List<Any>): SocketMessage {
            return SocketMessage(raw)
        }
    }
}
