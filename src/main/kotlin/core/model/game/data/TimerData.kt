package core.model.game.data

import io.ktor.util.date.*
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonPrimitive
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds

@Serializable
data class TimerData(
    val start: Long,
    val length: Long,
    val data: Map<String, JsonElement>? = null
) {
    companion object {
        fun runForDuration(
            duration: Duration,
            data: Map<String, Any>? = null
        ): TimerData {
            return TimerData(
                start = getTimeMillis(),
                length = duration.inWholeSeconds,
                data = data?.mapValues { toJsonElement(it.value) }
            )
        }

        private fun toJsonElement(value: Any?): JsonElement {
            return when (value) {
                null -> kotlinx.serialization.json.JsonNull
                is String -> JsonPrimitive(value)
                is Number -> JsonPrimitive(value)
                is Boolean -> JsonPrimitive(value)
                else -> JsonPrimitive(value.toString())
            }
        }
    }
}

@Serializable
data class SocketTimerData(
    val start: Long,
    val length: Long,
    val data: Map<String, JsonElement>? = null
)

fun TimerData.hasEnded(): Boolean {
    return getTimeMillis() >= this.start + this.length.seconds.inWholeMilliseconds
}