package server.messaging

import utils.parseJsonToMap

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

    fun get(key: String): Any? = map[key]

    fun contains(key: String): Boolean {
        return map.containsKey(key)
    }

    fun getString(key: String): String? = map[key] as? String
    fun getInt(key: String): Int? = (map[key] as? Number)?.toInt()

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
