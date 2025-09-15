package dev.deadzone.core.model.game.data

import dev.deadzone.utils.AnyMapSerializer
import io.ktor.util.date.*
import kotlinx.serialization.Serializable
import kotlin.time.Duration
import kotlin.time.Duration.Companion.seconds

@Serializable
data class TimerData(
    val start: Long, // epoch millis
    val length: Long, // length in seconds!
    // If sending this via API, the value should be JSONElement. Use Json.encodeToJsonElement()
    @Serializable(with = AnyMapSerializer::class)
    val data: Map<String, Any>? // this depends on each response. e.g., building upgrade need level
) {
    companion object {
        fun runForDuration(
            duration: Duration,
            data: Map<String, Any>? = emptyMap()
        ): TimerData {
            return TimerData(
                start = getTimeMillis(),
                length = duration.inWholeSeconds,
                data = data
            )
        }
    }
}

data class SocketTimerData(
    val start: Long, // epoch millis
    val length: Long, // length in seconds!
    // The value should be JSONElement. Use Json.encodeToJsonElement()
    @Serializable(with = AnyMapSerializer::class)
    val data: Map<String, Any>? // this depends on each response. e.g., building upgrade need level
)

fun TimerData.hasEnded(): Boolean {
    return getTimeMillis() >= this.start + this.length.seconds.inWholeMilliseconds
}
