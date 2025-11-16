package dev.deadzone.core.model.game.data

import common.AnyMapSerializer
import io.ktor.util.date.*
import kotlinx.serialization.Serializable
import kotlin.time.Duration
import kotlin.time.Duration.Companion.milliseconds
import kotlin.time.Duration.Companion.seconds
import kotlin.time.DurationUnit
import kotlin.time.toDuration

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

/**
 * Reduce the timer data length by [hours].
 *
 * **This will first calculate the remaining time before subtracting**
 *
 * @return `null` if the timer has finished after the reduction.
 * Returns a new TimerData with updated start time to reflect the speedup.
 */
fun TimerData.reduceBy(hours: Duration): TimerData? {
    if (this.hasEnded()) return null

    val remainingSeconds = this.secondsLeftToEnd().toDuration(DurationUnit.SECONDS)
    val reducedLength = remainingSeconds - hours
    if (reducedLength <= Duration.ZERO) return null

    // Create a new timer with current time as start, so the remaining time is correct
    return TimerData(
        start = getTimeMillis(),
        length = reducedLength.toLong(DurationUnit.SECONDS),
        data = this.data
    )
}

/**
 * Reduce the timer data length by half.
 *
 * **This will first calculate the remaining time before subtracting**
 *
 * @return `null` if the timer has finished after the reduction.
 * Returns a new TimerData with updated start time to reflect the speedup.
 */
fun TimerData.reduceByHalf(): TimerData? {
    if (this.hasEnded()) return null

    val remainingSeconds = this.secondsLeftToEnd().toDuration(DurationUnit.SECONDS)
    val reducedLength = remainingSeconds / 2
    if (reducedLength <= 1.seconds) return null

    // Create a new timer with current time as start, so the remaining time is correct
    return TimerData(
        start = getTimeMillis(),
        length = reducedLength.toLong(DurationUnit.SECONDS),
        data = this.data
    )
}

fun TimerData.hasEnded(): Boolean {
    return getTimeMillis() >= this.start + this.length.seconds.inWholeMilliseconds
}

fun TimerData.secondsLeftToEnd(): Int {
    if (this.hasEnded()) return 0
    return ((start.milliseconds + this.length.seconds) - getTimeMillis().milliseconds).toInt(DurationUnit.SECONDS)
}

/**
 * Change the length of the timer using the provided block.
 *
 * A `null` timer represent no timer is set or the timer has finished.
 *
 * @return `null` if timer was already `null`.
 */
fun TimerData?.changeLength(updateLength: (Duration?) -> Duration): TimerData? {
    if (this == null) return null
    return this.copy(length = updateLength(this.length.seconds).toLong(DurationUnit.SECONDS))
}

/**
 * Return `null` if time has finished (or less than 1 seconds).
 */
fun TimerData?.removeIfFinished(): TimerData? {
    if (this == null) return null
    return if (this.hasEnded() || this.secondsLeftToEnd() < 1) null else this
}
