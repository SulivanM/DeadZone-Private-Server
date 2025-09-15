package dev.deadzone.socket.messaging

import dev.deadzone.utils.parseJsonToMap

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
    fun getBoolean(key: String): Boolean? = map[key] as? Boolean
    fun getBytes(key: String): ByteArray? = map[key] as? ByteArray
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

    fun getList(key: String): List<Any?>? = map[key] as? List<*>

    fun keys(): Set<String> = map.keys
    fun values(): Collection<Any?> = map.values

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
