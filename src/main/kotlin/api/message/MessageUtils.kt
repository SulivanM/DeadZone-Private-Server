package api.message

import kotlinx.serialization.Serializable

/**
 * Key-value pair for message data
 */
@Serializable
data class KeyValuePair(
    val key: String = "",
    val value: String = "",
) {
    companion object {
        fun dummy(): KeyValuePair {
            return KeyValuePair(
                key = "examplekey",
                value = "examplevalue",
            )
        }
    }
}

/**
 * Extension function to convert a List of KeyValuePair to a Map
 */
fun List<KeyValuePair>.toMap(): Map<String, Any> {
    return this.associate { it.key to (it.value as Any) }
}

/**
 * Extension function to convert a Map to a List of KeyValuePair
 */
fun Map<String, Any>.toKeyValuePairList(): List<KeyValuePair> {
    return this.map { (key, value) -> KeyValuePair(key, value.toString()) }
}

/**
 * Write error arguments
 */
@Serializable
data class WriteErrorArgs(
    val source: String = "",
    val error: String = "",
    val details: String = "",
    val stacktrace: String = "",
    val extraData: List<KeyValuePair> = listOf(),
)

/**
 * Write error error response
 */
@Serializable
data class WriteErrorError(
    val errorCode: Int = 0,
    val message: String = "",
) {
    companion object {
        fun dummy(): WriteErrorError {
            return WriteErrorError(
                errorCode = 42,
                message = "Write error, error"
            )
        }
    }
}
